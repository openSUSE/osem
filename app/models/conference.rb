##
# This class represents a conference

class Conference < ActiveRecord::Base
  attr_accessible :title, :short_title, :social_tag, :contact_email, :timezone, :html_export_path,
                  :start_date, :end_date, :rooms_attributes, :tracks_attributes, :dietary_choices_attributes,
                  :use_dietary_choices, :use_supporter_levels, :supporter_levels_attributes, :social_events_attributes,
                  :event_types_attributes, :registration_start_date, :registration_end_date, :logo,
		              :questions_attributes, :question_ids, :answers_attributes, :answer_ids,
                  :difficulty_levels_attributes, :use_difficulty_levels,
                  :use_vpositions, :use_vdays, :vdays_attributes, :vpositions_attributes, :use_volunteers,
                  :media_id, :media_type, :color, :description,
                  :registration_description, :ticket_description

  has_paper_trail

  has_and_belongs_to_many :questions

  has_one :email_settings, :dependent => :destroy
  has_one :call_for_papers, :dependent => :destroy
  has_many :social_events, :dependent => :destroy
  has_many :supporter_registrations, :dependent => :destroy
  has_many :supporter_levels, :dependent => :destroy
  has_many :dietary_choices, :dependent => :destroy
  has_many :events, :dependent => :destroy
  has_many :event_types, :dependent => :destroy
  has_many :tracks, :dependent => :destroy
  has_many :difficulty_levels, :dependent => :destroy
  has_many :rooms, :dependent => :destroy
  has_many :registrations, :dependent => :destroy
  has_many :vdays, :dependent => :destroy
  has_many :vpositions, :dependent => :destroy
  has_many :vchoices, :dependent => :destroy

  belongs_to :venue

  accepts_nested_attributes_for :rooms, :reject_if => proc {|r| r["name"].blank?}, :allow_destroy => true
  accepts_nested_attributes_for :tracks, :reject_if => proc {|r| r["name"].blank?}, :allow_destroy => true
  accepts_nested_attributes_for :difficulty_levels, :allow_destroy => true
  accepts_nested_attributes_for :social_events, :allow_destroy => true
  accepts_nested_attributes_for :venue
  accepts_nested_attributes_for :dietary_choices, :allow_destroy => true
  accepts_nested_attributes_for :supporter_levels, :allow_destroy => true
  accepts_nested_attributes_for :event_types, :allow_destroy => true
  accepts_nested_attributes_for :email_settings
  accepts_nested_attributes_for :questions, :allow_destroy => true
  accepts_nested_attributes_for :vdays, :allow_destroy => true
  accepts_nested_attributes_for :vpositions, :allow_destroy => true

  has_attached_file :logo,
                    :styles => {:thumb => "100x100>", :large => "300x300>" }

  validates_attachment_content_type :logo,
                                    :content_type => [/jpg/, /jpeg/, /png/, /gif/],
                                    :size => { :in => 0..500.kilobytes }

  validates_presence_of :title,
                        :short_title,
                        :social_tag,
                        :start_date,
                        :end_date
  validates_uniqueness_of :short_title
  validates_format_of :short_title, :with => /\A[a-zA-Z0-9_-]*\z/
  before_create :generate_guid
  before_create :create_venue
  before_create :create_email_settings
  before_create :add_color

  def self.media_types
    media_types = {:youtube => 'YouTube', :slideshare => 'SlideShare',  :flickr => 'Flickr', :vimeo => 'Vimeo', :speakerdeck => 'Speakerdeck', :instagram => 'Instagram'}
    return media_types
  end


  ##
  # Checks if the user is registered to the conference
  #
  # ====Args
  # * +user+ -> The user we check for
  # ====Returns
  # * +nil+ -> If the user doesn't exist
  # * +false+ -> If the user is registered
  # * +true+ - If the user isn't registered
  def user_registered? user
    return nil if user.nil?
    return nil if user.person.nil?

    if self.registrations.where(:person_id => user.person.id).count == 0
      logger.debug("User #{user.email} isn't registered to self.title")
      return false
    else
      return true
    end
  end

  ##
  # Checks if the registration for the conference is currently open
  #
  # ====Returns
  # * +false+ -> If the conference dates are not set or today isn't in the
  #   registration period.
  # * +true+ -> If today is in the registration period.
  def registration_open?
    today = Date.current
    if registration_dates_given?
      (registration_start_date..registration_end_date).cover?(today)
    else
      false
    end
  end

  ##
  # Checks if the registration dates for the conference are provided
  #
  # ====Returns
  # * +false+ -> If the conference registration dates are not set
  # * +true+ -> If conference registration dates are set
  def registration_dates_given?
    if registration_start_date.blank? || registration_end_date.blank?
      false
    else
      true
    end
  end

  ##
  # Checks if the call for papers for the conference is currently open
  #
  # ====Returns
  # * +false+ -> If the CFP is not set or today isn't in the CFP period.
  # * +true+ -> If today is in the CFP period.
  def cfp_open?
    today = Date.current
    cfp = self.call_for_papers
    if !cfp.nil? && (cfp.start_date.. cfp.end_date).cover?(today)
      return true
    end

    return false
  end

  ##
  # Returns an array with the summarized event submissions per week.
  #
  # ====Returns
  #  * +Array+ -> e.g. [0, 3, 3, 5] -> first week 0 events, second week 3 events.
  def get_submissions_per_week
    result = []

    if call_for_papers && events
      submissions = events.group("strftime('%W', created_at)").count
      start_week = call_for_papers.start_week
      weeks = call_for_papers.weeks
      result = calculate_items_per_week(start_week, weeks, submissions)
    end
    result
  end

  ##
  # Returns an array with the summarized registrations per week.
  #
  # ====Returns
  #  * +Array+ -> e.g. [0, 3, 3, 5] -> first week 0, second week 3 registrations
  def get_registrations_per_week
    result = []

    if registrations &&
        registration_start_date &&
        registration_end_date

      reg = registrations.group("strftime('%W', created_at)").count
      start_week = get_registration_start_week
      weeks = registration_weeks
      result = calculate_items_per_week(start_week, weeks, reg)
    end
    result
  end

  ##
  # Calculates how many weeks the registration is.
  #
  # ====Returns
  # * +Integer+ -> start week
  def registration_weeks
    result = 0
    weeks = 0
    if registration_start_date && registration_end_date
      weeks = Date.new(registration_start_date.year, 12, 31).
          strftime('%W').to_i

      result = get_registration_end_week - get_registration_start_week + 1
    end
    result < 0 ? result + weeks : result
  end

  ##
  # Calculates how many weeks call for papers is.
  #
  # ====Returns
  # * +Integer+ -> weeks
  def cfp_weeks
    result = 0
    if call_for_papers
      result = call_for_papers.weeks
    end
    result
  end

  ##
  # Calculates the end week of the registration
  #
  # ====Returns
  # * +Integer+ -> start week
  def get_registration_start_week
    registration_start_date.strftime('%W').to_i
  end

  ##
  # Calculates the start week of the registration
  #
  # ====Returns
  # * +Integer+ -> start week
  def get_registration_end_week
    registration_end_date.strftime('%W').to_i
  end

  ##
  # Checks if the conference is pending.
  #
  # ====Returns
  # * +false+ -> If the conference start date is in the past.
  # * +true+ -> If the conference start date is in the future.
  def pending?
    start_date > Date.today
  end

  ##
  # Returns a hash with booleans with the required conference options.
  #
  # ====Returns
  # * +hash+ -> true -> filled / false -> missing
  def get_status
    result = {}
    result['registration'] = registration_date_set?
    result['cfp'] = cfp_set?
    result['venue'] = venue_set?
    result['rooms'] = rooms_set?
    result['tracks'] = tracks_set?
    result['event_types'] = event_types_set?
    result['difficulty_levels'] = difficulty_levels_set?
    result['process'] = calculate_setup_progress(result)
    result['short_title'] = short_title
    result
  end

  ##
  # Returns a hash with person => submissions ordered by submissions for all conferences
  #
  # ====Returns
  # * +hash+ -> person: submissions
  def self.get_top_submitter(limit = 5)
    submitter = EventPerson.where('event_role = ?', 'submitter').limit(limit).group(:person_id)
    counter = submitter.count
    calculate_person_submission_hash(submitter, counter)
  end

  ##
  # Returns a hash with person => submissions ordered by submissions
  #
  # ====Returns
  # * +hash+ -> person: submissions
  def get_top_submitter(limit = 5)
    submitter = EventPerson.joins(:event).
        where('event_role = ? and conference_id = ?', 'submitter', id).
        limit(limit).group(:person_id)

    counter = submitter.count
    Conference.calculate_person_submission_hash(submitter, counter)
  end

  ##
  # Returns a hash with event state => {value: count of event states, color: color}.
  # The result is calculated over all conferences.
  #
  # ====Returns
  # * +hash+ -> hash
  def self.event_distribution
    calculate_event_distribution_hash(Event.group(:state).count)
  end

  ##
  # Returns a hash with event state => {value: count of event states, color: color}
  #
  # ====Returns
  # * +hash+ -> hash
  def event_distribution
    Conference.calculate_event_distribution_hash(events.group(:state).count)
  end

  ##
  # Returns a hash with user distribution => {value: count of user state, color: color}
  # active: signed in during the last 3 months
  # unconfirmed: registered but not confirmed
  # dead: not signed in during the last year
  #
  # ====Returns
  # * +hash+ -> hash
  def self.user_distribution
    active_user = User.where('last_sign_in_at > ?', Date.today - 3.months).count
    unconfirmed_user = User.where('confirmed_at IS NULL').count
    dead_user = User.where('last_sign_in_at < ?', Date.today - 1.year).count

    calculate_user_distribution_hash(active_user, unconfirmed_user, dead_user)
  end

  private

  ##
  # Returns the progress of the set up conference list in percent
  #
  # ====Returns
  # * +Fixnum+ -> Progress in Percent
  def calculate_setup_progress(result)
    (result.select { |k, v| v }.length / result.length.to_f * 100).round(0).to_s
  end

  ##
  # Checks if there is a difficulty level.
  #
  # ====Returns
  # * +True+ -> One difficulty level or more
  # * +False+ -> No diffculty level
  def difficulty_levels_set?
    difficulty_levels.count > 0
  end

  ##
  # Checks if there is a difficulty level.
  #
  # ====Returns
  # * +True+ -> One difficulty level or more
  # * +False+ -> No diffculty level
  def event_types_set?
    event_types.count > 0
  end

  ##
  # Checks if there is a track.
  #
  # ====Returns
  # * +True+ -> One track or more
  # * +False+ -> No track
  def tracks_set?
    tracks.count > 0
  end

  ##
  # Checks if there is a room.
  #
  # ====Returns
  # * +True+ -> One room or more
  # * +False+ -> No room
  def rooms_set?
    rooms.count > 0
  end

  ##
  # Checks if venue has a name, address and website.
  #
  # ====Returns
  # * +True+ -> If venue has a name, address and website.
  # * +False+ -> venue has a no name, address or website.
  def venue_set?
    !!venue && !!venue.name && !!venue.address && !!venue.website
  end

  ##
  # Checks if the conference has a call for papers object.
  #
  # ====Returns
  # * +True+ -> If conference has a cfp object.
  # * +False+ -> If conference has no cfp object.
  def cfp_set?
    !!call_for_papers
  end

  ##
  # Checks if conference has a start and a end date.
  #
  # ====Returns
  # * +True+ -> If conference has a start and a end date.
  # * +False+ -> If conference has no start or end date.
  def registration_date_set?
    !!registration_start_date && !!registration_end_date
  end

  ##
  # Helper method for calculating hash with corresponding colors of user distribution states.
  #
  # ====Returns
  # * +hash+ -> hash
  def self.calculate_user_distribution_hash(active_user, unconfirmed_user, dead_user)
    result = {}
    if active_user > 0
      result['Active'] = {
        'color' => 'green',
        'value' => active_user
      }
    end
    if unconfirmed_user > 0
      result['Unconfirmed'] = {
        'color' => 'red',
        'value' => unconfirmed_user
      }
    end
    if dead_user > 0
      result['Dead'] = {
        'color' => 'black',
        'value' => dead_user
      }
    end
    result
  end

  ##
  # Helper method. Calculates hash with corresponding colors of event state distribution.
  #
  # ====Returns
  # * +hash+ -> hash
  def self.calculate_event_distribution_hash(states)
    result = {}
    states.each do |key, value|
      result[key.capitalize] =
          {
            'value' => value,
            'color' => Event.get_state_color(key)
          }
    end
    result
  end

  ##
  # Returns a hash with person => submissions ordered by submissions for all conferences
  #
  # ====Returns
  # * +hash+ -> person: submissions
  def self.calculate_person_submission_hash(submitter, counter)
    result = {}
    submitter.each do |s|
      result[s.person] = counter[s.person_id]
    end
    result
  end

  ##
  # Creates a venue and sets self.venue_id to it's id. Used as before_create.
  #
  def create_venue
    self.venue_id = Venue.create.id
    true
  end

  ##
  # Creates a EmailSettings association proxy. Used as before_create.
  #
  def create_email_settings
    build_email_settings
    true
  end

  ##
  # Creates a UID for the conference. Used as before_create.
  #
  def generate_guid
    begin
      guid = SecureRandom.urlsafe_base64
    end while Person.where(:guid => guid).exists?
    self.guid = guid
  end

  ##
  # Adds a random color to the conference
  #
  def add_color
    if !color
      self.color = %w(
        #000000 #0000FF #00FF00 #FF0000 #FFFF00 #9900CC
        #CC0066 #00FFFF #FF00FF #C0C0C0 #00008B #FFD700
        #FFA500 #FF1493 #FF00FF #F0FFFF #EE82EE #D2691E
        #C0C0C0 #A52A2A #9ACD32 #9400D3 #8B008B #8B0000
        #87CEEB #808080 #800080 #008B8B #006400
      ).sample
    end
  end

  # Calculates items per week from a hash.
  #
  # ====Returns
  #  * +Array+ -> e.g. [1, 3, 3, 5] -> first week 1, second week 2 registrations
  def calculate_items_per_week(start_week, weeks, items)
    sum = 0
    result = []
    last_key = start_week - 1

    if !items.empty? && start_week > items.keys[0].to_i
      start_week = items.keys[0].to_i
      weeks += start_week - items.keys[0].to_i + 1
    end

    items.each do |key, value|
      # Padding
      if last_key < (key.to_i - 1)
        result += Array.new(key.to_i - last_key - 1, sum)
      end

      sum += value
      result.push(sum)
      last_key = key.to_i
    end

    # Padding right
    if result.length < weeks
      result += Array.new(weeks - result.length, sum)
    end

    result
  end
end
