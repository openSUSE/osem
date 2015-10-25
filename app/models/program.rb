# cannot delete program if there are events submitted

class Program < ActiveRecord::Base
  belongs_to :conference

  has_one :cfp, dependent: :destroy
  has_many :event_types, dependent: :destroy
  has_many :tracks, dependent: :destroy
  has_many :difficulty_levels, dependent: :destroy
  has_many :rooms, dependent: :destroy
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

  accepts_nested_attributes_for :event_types, allow_destroy: true
  accepts_nested_attributes_for :tracks, reject_if: proc { |r| r['name'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :difficulty_levels, allow_destroy: true
  accepts_nested_attributes_for :rooms, reject_if: proc { |r| r['name'].blank? }, allow_destroy: true

  attr_accessible :schedule_fluid, :rating,
                  :schedule_public, :include_cfp_in_splash, :conference_id,
                  :event_types_attributes, :difficulty_levels_attributes, :rooms_attributes, :tracks_attributes

#   validates :conference_id, presence: true, uniqueness: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }

  before_create :create_event_types
  before_create :create_difficulty_levels

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
end
