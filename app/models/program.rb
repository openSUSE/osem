# cannot delete program if there are events submitted

class Program < ActiveRecord::Base
  belongs_to :conference

  has_one :cfp, dependent: :destroy
  has_many :event_types, dependent: :destroy
  has_many :tracks, dependent: :destroy
  has_many :difficulty_levels, dependent: :destroy
  has_many :schedules, dependent: :destroy
  has_many :events, dependent: :destroy do
    def require_registration
      where(require_registration: true, state: :confirmed)
    end

    def with_registration_open
      select { |e| e if e.registration_possible? }
    end

    # All confirmed events of the conference with attribute require_registration
    # excluding the events the user has already registered to
    def remaining_for_registration(registration)
      require_registration - registration.events
    end

    def confirmed
      where(state: :confirmed)
    end

    def scheduled(schedule_id)
      joins(:event_schedules).where('event_schedules.schedule_id = ?', schedule_id)
    end

    def unscheduled(schedule_id)
      select{ |e| e.unscheduled?(schedule_id) }
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

  accepts_nested_attributes_for :event_types, allow_destroy: true
  accepts_nested_attributes_for :tracks, reject_if: proc { |r| r['name'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :difficulty_levels, allow_destroy: true

#   validates :conference_id, presence: true, uniqueness: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10, only_integer: true }
  validate :voting_start_date_before_end_date
  validate :voting_dates_exist

  before_create :create_event_types
  before_create :create_difficulty_levels
  validate :check_languages_format

  ##
  # Checks if blind_voting is enabled and if voting period is over
  # ====Returns
  # * +true+ -> If we can show voting details
  # * +false+ -> If we cannot show voting details
  def show_voting?
    return true unless blind_voting

    Date.today > voting_end_date
  end

  ##
  # Checks if we are still in voting period
  # ====Returns
  # * +true+ -> If the voting period is not over yet
  # * +false+ -> If the voting period is over
  def voting_period?
    return false unless voting_start_date && voting_end_date

    (voting_start_date.to_datetime..voting_end_date.to_datetime).cover? Time.current
  end

  ##
  # Checks if both voting_start_date and voting_end_date are set
  # ====Returns
  # Errors when the condition is not true
  def voting_dates_exist
    errors.add(:voting_start_date, 'must be set, when blind voting is enabled') if blind_voting && !voting_start_date && !voting_end_date

    errors.add(:voting_end_date, 'must be set, when blind voting is enabled') if blind_voting && !voting_start_date && !voting_end_date

    errors.add(:voting_end_date, 'must be set, when voting_start_date is set') if voting_start_date && !voting_end_date

    errors.add(:voting_start_date, 'must be set, when voting_end_date is set') if voting_end_date && !voting_start_date
  end

  ##
  # Checks if voting_start_date is before voting_end_date
  # ====Returns
  # Errors when the condition is not true
  def voting_start_date_before_end_date
    errors.add(:voting_start_date, 'must be before voting end date') if voting_start_date && voting_end_date && voting_start_date > voting_end_date
  end

  ##
  # Checcks if the program has rating enabled
  #
  # ====Returns
  # * +false+ -> If rating is not enabled
  # * +true+ -> If rating is enabled
  def rating_enabled?
    self.rating && self.rating > 0
  end

  ##
  # Checks if the call for papers for the conference is currently open
  #
  # ====Returns
  # * +false+ -> If the CFP is not set or today isn't in the CFP period.
  # * +true+ -> If today is in the CFP period.
  def cfp_open?
    cfp = self.cfp

    cfp.present? && (cfp.start_date..cfp.end_date).cover?(Date.current)
  end

  def notify_on_schedule_public?
    return false unless conference.email_settings.send_on_program_schedule_public
    # do not notify if the schedule is not public
    return false unless schedule_public
    # do not notify unless the mail content is set up
    (!conference.email_settings.program_schedule_public_subject.blank? && !conference.email_settings.program_schedule_public_body.blank?)
  end

  def languages_list
    self.languages.split(',').map {|l| ISO_639.find(l).english_name} if self.languages.present?
  end

  ##
  # Checks if there is any event in the program that starts in the given date
  #
  # ====Returns
  # * +True+ -> If there is any event for the given date
  # * +False+ -> If there is not any event for the given date
  def any_event_for_this_date?(date)
    parsed_date = DateTime.parse("#{date} 00:00").utc
    events.where(start_time: parsed_date..(parsed_date + 1)).any?
  end

  private

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
  # Check if languages string has the right format. Used as validation.
  #
  def check_languages_format
    return unless self.languages.present?
    # All white spaces are removed to allow languages to be separated by ',' and ', '. The languages string without spaces is saved
    self.languages = self.languages.delete(' ').downcase
    errors.add(:languages, 'must be two letters separated by commas') && return unless
    self.languages.match(/^$|(\A[a-z][a-z](,[a-z][a-z])*\z)/).present?
    languages_array = self.languages.split(',')
    # We check that languages are not repeated
    errors.add(:languages, "can't be repeated") && return unless languages_array.uniq!.nil?
    # We check if every language is a valid ISO 639-1 language
    errors.add(:languages, 'must be ISO 639-1 valid codes') unless languages_array.select{ |x| ISO_639.find(x).nil? }.empty?
  end
end
