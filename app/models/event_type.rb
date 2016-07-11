class EventType < ActiveRecord::Base
  belongs_to :program
  has_many :events, dependent: :restrict_with_error

  validates :title, presence: true
  validates :length, numericality: {greater_than: 0}
  validates :minimum_abstract_length, presence: true
  validates :maximum_abstract_length, presence: true
  validate :length_step
  validates :color, format: /\A#[0-9A-F]{6}\z/

  before_validation :capitalize_color

  alias_attribute :name, :title

  # If LENGTH_STEP must be divisor of 60, otherwise the schedule wont be displayed properly
  LENGTH_STEP = 15

  private

  ##
  # Check if length is multiple of LENGTH_STEP. Used as validation.
  #
  def length_step
    errors.add(:length, "must be multiple of #{LENGTH_STEP}") if length % LENGTH_STEP != 0
  end

  def capitalize_color
    self.color = color.upcase if color.present?
  end
end
