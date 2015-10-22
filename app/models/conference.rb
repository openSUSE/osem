##
# This class represents a conference
# rubocop:disable Metrics/ClassLength
class Conference < ActiveRecord::Base
  require 'uri'
  serialize :events_per_week, Hash
  resourcify # Needed to call 'Conference.with_role' in /models/ability.rb

  default_scope { order('start_date DESC') }

  attr_accessible :title, :short_title, :description, :timezone, :html_export_path,
                  :start_date, :end_date, :rooms_attributes, :tracks_attributes,
                  :dietary_choices_attributes, :use_dietary_choices,
                  :tickets_attributes, :social_events_attributes, :event_types_attributes,
                  :logo, :questions_attributes,
                  :question_ids, :answers_attributes, :answer_ids, :difficulty_levels_attributes,
                  :use_difficulty_levels, :use_vpositions, :use_vdays, :vdays_attributes,
                  :vpositions_attributes, :use_volunteers, :color,
                  :sponsorship_levels_attributes, :sponsors_attributes,
                  :photos_attributes, :targets, :targets_attributes,
                  :campaigns, :campaigns_attributes

  has_paper_trail

  has_and_belongs_to_many :questions

  has_one :splashpage, dependent: :destroy
  has_one :contact, dependent: :destroy
  has_one :registration_period, dependent: :destroy
  has_one :email_settings, dependent: :destroy
  has_one :call_for_paper, dependent: :destroy
  has_one :venue, dependent: :destroy
  has_many :social_events, dependent: :destroy
  has_many :ticket_purchases, dependent: :destroy
  has_many :supporters, through: :ticket_purchases, source: :user
  has_many :tickets, dependent: :destroy
  has_many :dietary_choices, dependent: :destroy
  has_many :events, dependent: :destroy do
    def workshops
      where(require_registration: true, state: :confirmed)
    end

    def confirmed
      where(state: :confirmed)
    end

    def scheduled
      where.not(start_time: nil)
    end

    def highlights
      where(state: :confirmed, is_highlight: true)
    end
  end
  has_many :event_users, through: :events
  has_many :speakers, -> { distinct }, through: :event_users, source: :user do
    def confirmed
      joins(:events).where(events: { state: :confirmed })
    end
  end
  has_many :event_types, dependent: :destroy
  has_many :tracks, dependent: :destroy
  has_many :difficulty_levels, dependent: :destroy
  has_many :rooms, dependent: :destroy
  has_many :lodgings, dependent: :destroy
  has_many :registrations, dependent: :destroy
  has_many :participants, through: :registrations, source: :user
  has_many :vdays, dependent: :destroy
  has_many :vpositions, dependent: :destroy
  has_many :sponsorship_levels, -> { order('position ASC') }, dependent: :destroy
  has_many :sponsors, dependent: :destroy
  has_many :photos, dependent: :destroy
  has_many :targets, dependent: :destroy
  has_many :campaigns, dependent: :destroy
  has_many :commercials, as: :commercialable, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  accepts_nested_attributes_for :rooms, reject_if: proc { |r| r['name'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :tracks, reject_if: proc { |r| r['name'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :difficulty_levels, allow_destroy: true
  accepts_nested_attributes_for :social_events, allow_destroy: true
  accepts_nested_attributes_for :venue
  accepts_nested_attributes_for :dietary_choices, allow_destroy: true
  accepts_nested_attributes_for :tickets, allow_destroy: true
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

  validates_presence_of :title,
                        :short_title,
                        :start_date,
                        :end_date

  validates_uniqueness_of :short_title
  validates_format_of :short_title, with: /\A[a-zA-Z0-9_-]*\z/
  before_create :generate_guid
  before_create :create_event_types
  before_create :create_difficulty_levels
  before_create :create_email_settings
  before_create :add_color

  def date_range_string
    startstr = 'Unknown - '
    endstr = 'Unknown'
    if start_date.month == end_date.month && start_date.year == end_date.year
      startstr = start_date.strftime('%B %d - ')
      endstr = end_date.strftime('%d, %Y')
    elsif start_date.month != end_date.month && start_date.year == end_date.year
      startstr = start_date.strftime('%B %d - ')
      endstr = end_date.strftime('%B %d, %Y')
    else
      startstr = start_date.strftime('%B %d, %Y - ')
      endstr = end_date.strftime('%B %d, %Y')
    end

    result = startstr + endstr
    result
  end

  ##
  # Checks if the user is registered to the conference
  #
  # ====Args
  # * +user+ -> The user we check for
  # ====Returns
  # * +false+ -> If the user is registered
  # * +true+ - If the user isn't registered
  def user_registered? user
    user.present? && registrations.where(user_id: user.id).count > 0
  end

  ##
  # Checks if the registration for the conference is currently open
  #
  # ====Returns
  # * +false+ -> If the conference dates are not set or today isn't in the
  #   registration period.
  # * +true+ -> If today is in the registration period.
  def registration_open?
    registration_dates_given? &&
      (registration_period.start_date..registration_period.end_date).cover?(Date.current)
  end

  ##
  # Checks if the registration dates for the conference are provided
  #
  # ====Returns
  # * +false+ -> If the conference registration dates are not set
  # * +true+ -> If conference registration dates are set
  def registration_dates_given?
    registration_period.present? &&
      registration_period.start_date.present? &&
      registration_period.end_date.present?
  end

  ##
  # Checks if the call for papers for the conference is currently open
  #
  # ====Returns
  # * +false+ -> If the CFP is not set or today isn't in the CFP period.
  # * +true+ -> If today is in the CFP period.
  def cfp_open?
    cfp = self.call_for_paper

    cfp.present? && (cfp.start_date..cfp.end_date).cover?(Date.current)
  end

  ##
  # Returns an array with the summarized event submissions per week.
  #
  # ====Returns
  #  * +Array+ -> e.g. [0, 3, 3, 5] -> first week 0 events, second week 3 events.
  def get_submissions_per_week
    result = []

    if call_for_paper && events
      submissions = events.group(:week).count
      start_week = call_for_paper.start_week
      weeks = call_for_paper.weeks
      result = calculate_items_per_week(start_week, weeks, submissions)
    end
    result
  end

  ##
  # Returns an hash with submitted, confirmed and unconfirmed event submissions
  # per week.
  #
  # ====Returns
  #  * +Array+ -> e.g. 'Submitted' => [0, 3, 3, 5]  -> first week 0 events, second week 3 events.
  def get_submissions_data
    result = {}
    if call_for_paper && events
      result = get_events_per_week_by_state

      start_week = call_for_paper.start_week
      end_week = end_date.strftime('%W').to_i
      weeks = weeks(start_week, end_week)

      result.each do |state, values|
        if state == 'Submitted'
          result['Submitted'] = pad_array_left_kumulative(start_week, values)
        else
          result[state] = pad_array_left_not_kumulative(start_week, values)
        end
      end
      result['Weeks'] = weeks > 0 ? (1..weeks).to_a : 0
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
       registration_period &&
       registration_period.start_date &&
       registration_period.end_date

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
    if registration_period &&
       registration_period.start_date &&
       registration_period.end_date
      weeks = Date.new(registration_period.start_date.year, 12, 31).
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
    if call_for_paper
      call_for_paper.weeks
    else
      0
    end
  end

  ##
  # Calculates the end week of the registration
  #
  # ====Returns
  # * +Integer+ -> start week
  def get_registration_start_week
    if registration_period
      registration_period.start_date.strftime('%W').to_i
    else
      -1
    end
  end

  ##
  # Calculates the start week of the registration
  #
  # ====Returns
  # * +Integer+ -> start week
  def get_registration_end_week
    if registration_period
      registration_period.end_date.strftime('%W').to_i
    else
      -1
    end
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
    result = {
      registration: registration_date_set?,
      cfp: cfp_set?,
      venue: venue_set?,
      rooms: rooms_set?,
      tracks: tracks_set?,
      event_types: event_types_set?,
      difficulty_levels: difficulty_levels_set?,
      splashpage: splashpage && splashpage.public?
    }

    result.update(
      process: calculate_setup_progress(result),
      short_title: short_title
    ).with_indifferent_access
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
    calculate_event_distribution_hash(Event.select(:state).group(:state).count)
  end

  ##
  # Returns a hash with event state => {value: count of event states, color: color}
  #
  # ====Returns
  # * +hash+ -> hash
  def event_distribution
    Conference.calculate_event_distribution_hash(events.select(:state).group(:state).count)
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
  # Calculates the overall program minutes
  #
  # ====Returns
  # * +hash+ -> Fixnum minutes
  def current_program_minutes
    events_grouped = events.select(:event_type_id).group(:event_type_id)
    events_counted = events_grouped.count
    calculate_program_minutes(events_grouped, events_counted)
  end

  ##
  # Calculates the overall program hours
  #
  # ====Returns
  # * +Fixnum+ -> Fixnum hours. Example: 1.5 gets rounded to 2. 1.3 gets rounded 1.
  def current_program_hours
    (current_program_minutes / 60.to_f).round
  end

  ##
  # Calculates the overall program minutes since date
  #
  # ====Returns
  # * +hash+ -> Fixnum minutes
  def new_program_minutes(date)
    events_grouped = events.select(:event_type_id).where('created_at > ?', date).group(:event_type_id)
    events_counted = events_grouped.count
    calculate_program_minutes(events_grouped, events_counted)
  end

  ##
  # Calculates the overall program hours since date
  #
  # ====Returns
  # * +Fixnum+ -> Fixnum hours
  def new_program_hours(date)
    (new_program_minutes(date) / 60.to_f).round
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
      tracks_grouped = events.select(:track_id).where('state = ?', state).group(:track_id)
    else
      tracks_grouped = events.select(:track_id).group(:track_id)
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
             select('id, short_title, color, start_date')

    if result.length == 0
      result = Conference.
               select('id, short_title, color, start_date').limit(2).
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
    result = Conference.select('id, short_title, color, start_date').order(start_date: :desc)
    result - active_conferences
  end

  ##
  # A list with the three event states submitted, confirmed, unconfirmed with corresponding colors
  #
  # ====Returns
  # * +List+
  def self.get_event_state_line_colors
    [
      { short_title: 'Submitted', color: 'blue' },
      { short_title: 'Confirmed', color: 'green' },
      { short_title: 'Unconfirmed', color: 'orange' }
    ]
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

  ##
  # Writes an snapshot of the actual event distribution to the database
  # Triggered each every Sunday 11:55 pm form whenever (config/schedule.rb).
  #
  def self.write_event_distribution_to_db
    week = DateTime.now.end_of_week

    Conference.where('end_date > ?', Date.today).each do |conference|
      result = {}
      Event.state_machine.states.each do |state|
        count = conference.events.where('state = ?', state.name).count
        result[state.name] = count
      end

      if !conference.events_per_week
        conference.events_per_week = {}
      end

      # Write to database
      conference.events_per_week[week] = result
      conference.save!
    end
  end

  ##
  # Checks if conference is updated for email notifications.
  #
  # ====Returns
  # * +True+ -> If conference is updated and all other parameters are set
  # * +False+ -> Either conference is not updated or one or more parameter is not set
  def notify_on_dates_changed?
    (self.start_date_changed? || self.end_date_changed?) &&
      self.email_settings.send_on_updated_conference_dates &&
      !self.email_settings.updated_conference_dates_subject.blank? &&
      self.email_settings.updated_conference_dates_template
  end

  ##
  # Checks if registration dates are updated for email notifications.
  #
  # ====Returns
  # * +True+ -> If registration dates is updated and all other parameters are set
  # * +False+ -> Either registration date is not updated or one or more parameter is not set
  def notify_on_registration_dates_changed?
    registration_period &&
      (registration_period.start_date_changed? || registration_period.end_date_changed?) &&
      email_settings.send_on_updated_conference_registration_dates &&
      !email_settings.updated_conference_registration_dates_subject.blank? &&
      email_settings.updated_conference_registration_dates_template
  end

  private

  after_create do
    self.create_contact
  end

  ##
  # Calculates the weeks from a start and a end week.
  #
  # ====Returns
  # * +Fixnum+ -> weeks
  def weeks(start_week, end_week)
    weeks = end_week - start_week + 1
    weeks_of_year = Date.new(start_date.year, 12, 31).strftime('%W').to_i
    weeks < 0 ? weeks + weeks_of_year : weeks
  end

  ##
  # Returns a Hash with the events with the state confirmend / unconfirmed per week.
  #
  # ====Returns
  # * +Hash+ -> e.g. 'Confirmed' => { 3 => 5, 4 => 6 }
  def get_events_per_week_by_state
    result = {
      'Submitted' => {},
      'Confirmed' => {},
      'Unconfirmed' => {}
    }

    # Completed weeks
    events_per_week.each do |week, values|
      values.each do |state, value|
        if [:confirmed, :unconfirmed].include?(state)
          if !result[state.to_s.capitalize]
            result[state.to_s.capitalize] = {}
          end
          result[state.to_s.capitalize][week.strftime('%W').to_i] = value
        end
      end
    end

    # Actual week
    this_week = Date.today.end_of_week.strftime('%W').to_i
    result['Confirmed'][this_week] = events.where('state = ?', :confirmed).count
    result['Unconfirmed'][this_week] = events.where('state = ?', :unconfirmed).count
    result['Submitted'] = events.select(:week).group(:week).count
    result['Submitted'][this_week] = events.where(week: this_week).count
    result
  end

  ##
  # Returns an array from the hash values with left padding.
  #
  # ====Returns
  # * +Array+ -> [0, 0, 1, 2, 3, 0, 0]
  def pad_array_left_not_kumulative(start_week, hash)
    hash = assert_keys_are_continuously(hash)

    first_week = hash.keys[0]
    left = pad_left(first_week, start_week)
    left + hash.values
  end

  ##
  # Returns an array from the hash values with left padding.
  #
  # ====Returns
  # * +Array+ -> [0, 0, 1, 2, 3, 3, 3]
  def pad_array_left_kumulative(start_week, hash)
    hash = assert_keys_are_continuously(hash)
    result = cumulative_sum(hash.values)

    first_week = hash.keys[0]
    left = pad_left(first_week, start_week)
    left + result
  end

  ##
  # Cumulative sums an array.
  #
  # ====Returns
  # * +Array+ -> [1, 2, 3, 4] --> [1, 3, 7, 11]
  def cumulative_sum(array)
    sum = 0
    array.map { |x| sum += x }
  end

  ##
  # Returns the left padding.
  #
  # ====Returns
  # * +Array+
  def pad_left(first_week, start_week)
    left = []
    if first_week > start_week
      left = Array.new(first_week - start_week - 1, 0)
    end
    left
  end

  ##
  # Asserts that all keys in the hash are continuously.
  # If not, the missing key is inserted with value 0.
  #
  # ====Returns
  # * +Hash+  { 1 => 1, 2 => 0, 3 => 0, 4 => 3 }
  def assert_keys_are_continuously(hash)
    keys = hash.keys
    (keys.min..keys.max).each do |key|
      if !hash[key]
        hash[key] = 0
      end
    end
    Hash[ hash.sort ]
  end

  ##
  # Returns the progress of the set up conference list in percent
  #
  # ====Returns
  # * +String+ -> Progress in Percent
  def calculate_setup_progress(result)
    (100 * result.values.count(true) / result.values.count).to_s
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

  # Checks if the conference has a venue object.
  #
  # ====Returns
  # * +True+ -> If conference has a venue object.
  # * +False+ -> IF conference has no venue object.
  def venue_set?
    !!venue
  end

  ##
  # Checks if the conference has a call for papers object.
  #
  # ====Returns
  # * +True+ -> If conference has a cfp object.
  # * +False+ -> If conference has no cfp object.
  def cfp_set?
    !!call_for_paper
  end

  ##
  # Checks if conference has a start and a end date.
  #
  # ====Returns
  # * +True+ -> If conference has a start and a end date.
  # * +False+ -> If conference has no start or end date.
  def registration_date_set?
    !!registration_period && !!registration_period.start_date && !!registration_period.end_date
  end

  # Calculates the distribution from events.
  #
  # ====Returns
  # * +hash+ -> object_type => {color, value}
  def calculate_event_distribution(group_by_id, association_symbol, state = nil)
    if state
      grouped = events.select(group_by_id).where('state = ?', 'confirmed').group(group_by_id)
    else
      grouped = events.select(group_by_id).group(group_by_id)
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
  # Helper method to calculate the program minutes.
  #
  # ====Returns
  # * +Fixnums+ summed program minutes
  def calculate_program_minutes(events_grouped, events_counted)
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
  # Creates default EventTypes for this Conference. Used as before_create.
  #
  def create_event_types
    event_types << EventType.create(title: 'Talk', length: 30, color: '#FF0000', description: 'Presentation in lecture format',
                                    minimum_abstract_length: 0,
                                    maximum_abstract_length: 500)
    event_types << EventType.create(title: 'Workshop', length: 60, color: '#0000FF', description: 'Interactive hands-on practice',
                                    minimum_abstract_length: 0,
                                    maximum_abstract_length: 500)
    true
  end

  ##
  # Creates default DifficultyLevels for this Conference. Used as before_create.
  #
  def create_difficulty_levels
    difficulty_levels << DifficultyLevel.create(title: 'Easy',
                                                description: 'Events are understandable for everyone without knowledge of the topic.',
                                                color: '#70EF69')
    difficulty_levels << DifficultyLevel.create(title: 'Medium',
                                                description: 'Events require a basic understanding of the topic.',
                                                color: '#EEEF69')
    difficulty_levels << DifficultyLevel.create(title: 'Hard',
                                                description: 'Events require expert knowledge of the topic.',
                                                color: '#EF6E69')
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
