##
# This class represents a conference

class Conference < ActiveRecord::Base
  require 'uri'

  attr_accessible :title, :short_title, :social_tag, :contact_email, :timezone, :html_export_path,
                  :start_date, :end_date, :rooms_attributes, :tracks_attributes,
                  :dietary_choices_attributes, :use_dietary_choices, :use_supporter_levels,
                  :supporter_levels_attributes, :social_events_attributes, :event_types_attributes,
                  :registration_start_date, :registration_end_date, :logo, :questions_attributes,
                  :question_ids, :answers_attributes, :answer_ids, :difficulty_levels_attributes,
                  :use_difficulty_levels, :use_vpositions, :use_vdays, :vdays_attributes,
                  :vpositions_attributes, :use_volunteers, :media_id, :media_type, :color,
                  :description, :registration_description, :ticket_description,
                  :sponsorship_levels_attributes, :sponsors_attributes, :facebook_url, :google_url,
                  :twitter_url, :sponsor_description, :sponsor_email, :lodging_description,
                  :include_registrations_in_splash, :include_sponsors_in_splash,
                  :include_tracks_in_splash, :include_tickets_in_splash,
                  :include_social_media_in_splash, :include_program_in_splash,
                  :make_conference_public, :photos_attributes, :banner_photo,
                  :include_banner_in_splash, :targets, :targets_attributes, :campaigns,
                  :campaigns_attributes, :instagram_url

  has_paper_trail

  has_and_belongs_to_many :questions

  has_one :email_settings, dependent: :destroy
  has_one :call_for_papers, dependent: :destroy
  has_many :social_events, dependent: :destroy
  has_many :supporter_registrations, dependent: :destroy
  has_many :supporter_levels, dependent: :destroy
  has_many :dietary_choices, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :event_types, dependent: :destroy
  has_many :tracks, dependent: :destroy
  has_many :difficulty_levels, dependent: :destroy
  has_many :rooms, dependent: :destroy
  has_many :registrations, dependent: :destroy
  has_many :vdays, dependent: :destroy
  has_many :vpositions, dependent: :destroy
  has_many :vchoices, dependent: :destroy
  has_many :sponsorship_levels, dependent: :destroy
  has_many :sponsors, dependent: :destroy
  has_many :photos, dependent: :destroy
  has_many :targets, dependent: :destroy
  has_many :campaigns, dependent: :destroy
  belongs_to :venue

  accepts_nested_attributes_for :rooms, reject_if: proc { |r| r['name'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :tracks, reject_if: proc { |r| r['name'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :difficulty_levels, allow_destroy: true
  accepts_nested_attributes_for :social_events, allow_destroy: true
  accepts_nested_attributes_for :venue
  accepts_nested_attributes_for :dietary_choices, allow_destroy: true
  accepts_nested_attributes_for :supporter_levels, allow_destroy: true
  accepts_nested_attributes_for :sponsorship_levels, allow_destroy: true
  accepts_nested_attributes_for :sponsors, allow_destroy: true
  accepts_nested_attributes_for :event_types, allow_destroy: true
  accepts_nested_attributes_for :email_settings
  accepts_nested_attributes_for :questions, allow_destroy: true
  accepts_nested_attributes_for :vdays, allow_destroy: true
  accepts_nested_attributes_for :vpositions, allow_destroy: true
  accepts_nested_attributes_for :photos, allow_destroy: true
  accepts_nested_attributes_for :targets, allow_destroy: true
  accepts_nested_attributes_for :campaigns, allow_destroy: true

  has_attached_file :logo,
                    styles: { thumb: '100x100>', large: '300x300>' }

  validates_attachment_content_type :logo,
                                    content_type: [/jpg/, /jpeg/, /png/, /gif/],
                                    size: { in: 0..500.kilobytes }

  has_attached_file :banner_photo,
                    styles: { thumb: '100x100>', large: '1300x700>' }

  validates_attachment_content_type :banner_photo,
                                    content_type: [/jpg/, /jpeg/, /png/, /gif/],
                                    size: { in: 0..500.kilobytes }
  validates_presence_of :title,
                        :short_title,
                        :social_tag,
                        :start_date,
                        :end_date

  validates :facebook_url, :twitter_url, :google_url,
            format: URI::regexp(%w(http https)), allow_blank: true

  validates_uniqueness_of :short_title
  validates_format_of :short_title, :with => /\A[a-zA-Z0-9_-]*\z/
  before_create :generate_guid
  before_create :create_venue
  before_create :create_email_settings
  before_create :add_color

  def self.media_types
    media_types = { youtube: 'YouTube', slideshare: 'SlideShare', flickr: 'Flickr', vimeo: 'Vimeo',
                    speakerdeck: 'Speakerdeck', instagram: 'Instagram' }
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

    if registrations.where(user_id: user.id).count == 0
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
      submissions = events.group(:week).count
      start_week = call_for_papers.start_week
      weeks = call_for_papers.weeks
      result = calculate_items_per_week(start_week, weeks, submissions)
    end
    result
  end

  ##
  # Returns an array with the summarized event submissions per week.
  #
  # ====Returns
  #  * +Array+ -> e.g. [0, 3, 3, 5] -> first week 0 events, second week 3 events.
  def get_submissions_per_week_by_status(state)
    result = []

    if call_for_papers && events
      submissions = events.where('state = ?', state).group(:week).count
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

      reg = registrations.group(:week).count
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
    result['make_conference_public'] = make_conference_public?
    result['process'] = calculate_setup_progress(result)
    result['short_title'] = short_title
    result
  end

  ##
  # Returns a hash with user => submissions ordered by submissions for all conferences
  #
  # ====Returns
  # * +hash+ -> user: submissions
  def self.get_top_submitter(limit = 5)
    submitter = EventUser.where('event_role = ?', 'submitter').limit(limit).group(:user_id)
    counter = submitter.order('count_all desc').count
    calculate_user_submission_hash(submitter, counter)
  end

  ##
  # Returns a hash with user => submissions ordered by submissions
  #
  # ====Returns
  # * +hash+ -> user: submissions
  def get_top_submitter(limit = 5)
    submitter = EventUser.joins(:event).
        where('event_role = ? and conference_id = ?', 'submitter', id).
        limit(limit).group(:user_id)
    counter = submitter.order('count_all desc').count
    Conference.calculate_user_submission_hash(submitter, counter)
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

  ##
  # Calculates the overall programm hours
  #
  # ====Returns
  # * +hash+ -> Fixnum hours
  def current_program_hours
    events_grouped = events.group(:event_type_id)
    events_counted = events_grouped.count
    calculate_program_hours(events_grouped, events_counted)
  end

  ##
  # Calculates the overall programm hours since date
  #
  # ====Returns
  # * +hash+ -> Fixnum hours
  def new_program_hours(date)
    events_grouped = events.where('created_at > ?', date).group(:event_type_id)
    events_counted = events_grouped.count
    calculate_program_hours(events_grouped, events_counted)
  end

  ##
  # Calculates the difficulty level distribution from all events.
  #
  # ====Returns
  # * +hash+ -> difficulty level => {color, value}
  def difficulty_levels_distribution(state = nil)
    calculate_event_distribution(:difficulty_level_id, :difficulty_level, state)
  end

  ##
  # Calculates the event_type distribution from all events.
  #
  # ====Returns
  # * +hash+ -> event_type => {color, value}
  def event_type_distribution(state = nil)
    calculate_event_distribution(:event_type_id, :event_type, state)
  end

  ##
  # Calculates the track distribution from all events.
  #
  # ====Returns
  # * +hash+ -> track => {color, value}
  def tracks_distribution(state = nil)
    if state
      tracks_grouped = events.where('state = ?', state).group(:track_id)
    else
      tracks_grouped = events.group(:track_id)
    end
    tracks_counted = tracks_grouped.count

    calculate_track_distribution_hash(tracks_grouped, tracks_counted)
  end

  ##
  # Return all pending conferences. If there are no pending conferences, the last two
  # past conferences are returned
  #
  # ====Returns
  # * +ActiveRecord+
  def self.get_active_conferences_for_dashboard
    result = Conference.where('start_date > ?', Time.now).
        select('id, short_title, color, start_date,
        registration_end_date, registration_start_date')

    if result.length == 0
      result = Conference.
          select('id, short_title, color, start_date, registration_end_date,
          registration_start_date').limit(2).
          order(start_date: :desc)
    end
    result
  end

  ##
  # Return all conferences minus the active conferences
  #
  # ====Returns
  # * +ActiveRecord+
  def self.get_conferences_without_active_for_dashboard(active_conferences)
    result = Conference.select('id, short_title, color, start_date,
              registration_end_date, registration_start_date').order(start_date: :desc)
    result - active_conferences
  end

  ##
  # A list with the three event states submitted, confirmed, unconfirmed with corresponding colors
  #
  # ====Returns
  # * +List+
  def self.get_event_state_line_colors
    result = []
    result.push(short_title: 'Submitted', color: 'blue')
    result.push(short_title: 'Confirmed', color: 'green')
    result.push(short_title: 'Unconfirmed', color: 'orange')
    result
  end

  ##
  # A map with all conference targets with progress in percent of a certain unit.
  #
  # ====Returns
  # * +Map+ -> target => progress
  def get_targets(target_unit)
    conference_target = targets.where('unit = ?', target_unit)
    result = {}
    conference_target.each do |target|
      result[target.to_s] = target.get_progress
    end
    result
  end

  ##
  # A map with all conference campaigns associated with targets.
  #
  # ====Returns
  # * +Map+ -> campaign => {actual, target, progress}
  def get_campaigns
    result = {}
    campaigns.each do |campaign|
      campaign.targets.each do |target|
        result["#{target} from #{campaign.name}"] = target.get_campaign
      end
    end
    result
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

  # Calculates the distribution from events.
  #
  # ====Returns
  # * +hash+ -> object_type => {color, value}
  def calculate_event_distribution(group_by_id, association_symbol, state = nil)
    if state
      grouped = events.where('state = ?', 'confirmed').group(group_by_id)
    else
      grouped = events.group(group_by_id)
    end
    counted = grouped.count

    calculate_distribution_hash(grouped, counted, association_symbol)
  end

  ##
  # Helper method to calculate the correct data format for the doughnut charts.
  #
  # ====Returns
  # * +hash+ -> object_type => {color, value}
  def calculate_distribution_hash(grouped, counter, symbol)
    result = {}

    grouped.each do |event|
      object = event.send(symbol)
      if object
        result[object.title] = {
          'value' => counter[object.id],
          'color' => object.color
        }
      end
    end
    result
  end

  ##
  # Helper method to calculate the correct data format for the doughnut charts
  # for track distribution of events.
  #
  # ====Returns
  # * +hash+ -> object_type => {color, value}
  def calculate_track_distribution_hash(tracks_grouped, tracks_counter)
    result = {}
    tracks_grouped.each do |event|
      if event.track
        result[event.track.name] = {
          'value' => tracks_counter[event.track_id],
          'color' => event.track.color
        }
      end
    end
    result
  end

  ##
  # Helper method to calculate the program hours.
  #
  # ====Returns
  # * +Fixnums+ summed programm hours
  def calculate_program_hours(events_grouped, events_counted)
    result = 0
    events_grouped.each do |event|
      result += events_counted[event.event_type_id] * event.event_type.length
    end
    result
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
  # Returns a hash with user => submissions ordered by submissions for all conferences
  #
  # ====Returns
  # * +hash+ -> user: submissions
  def self.calculate_user_submission_hash(submitters, counter)
    result = ActiveSupport::OrderedHash.new
    counter.each do |key, value|
      submitter = submitters.where(user_id: key).first
      if submitter
        result[submitter.user] = value
      end
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
    guid = SecureRandom.urlsafe_base64
#     begin
#       guid = SecureRandom.urlsafe_base64
#     end while User.where(:guid => guid).exists?
    self.guid = guid
  end

  ##
  # Adds a random color to the conference
  #
  def add_color
    if !color
      self.color = get_color
    end
  end

  def get_color
    %w(
        #000000 #0000FF #00FF00 #FF0000 #FFFF00 #9900CC
        #CC0066 #00FFFF #FF00FF #C0C0C0 #00008B #FFD700
        #FFA500 #FF1493 #FF00FF #F0FFFF #EE82EE #D2691E
        #C0C0C0 #A52A2A #9ACD32 #9400D3 #8B008B #8B0000
        #87CEEB #808080 #800080 #008B8B #006400
      ).sample
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
