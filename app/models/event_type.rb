class EventType < ActiveRecord::Base
  belongs_to :program
  has_many :events, dependent: :restrict_with_error

  has_paper_trail meta: { conference_id: :conference_id }

  validates :title, presence: true
  validates :length, numericality: {greater_than: 0}
  validates :minimum_abstract_length, presence: true
  validates :maximum_abstract_length, presence: true
  validate :length_step
  validates :color, format: /\A#[0-9A-F]{6}\z/

  before_validation :capitalize_color

  alias_attribute :name, :title

  private

  ##
  # Check if length is a divisor of program schedule cell size. Used as validation.
  #
  def length_step
    errors.add(:length, "must be a divisor of #{program.schedule_interval}") if program && length % program.schedule_interval != 0
  end

  def capitalize_color
    self.color = color.upcase if color.present?
  end

  def conference_id
    program.conference_id
  end
end
