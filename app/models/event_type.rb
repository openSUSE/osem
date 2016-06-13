class EventType < ActiveRecord::Base
  belongs_to :program
  has_many :events, dependent: :restrict_with_error

  validates :title, presence: true
  validates :length, numericality: {greater_than: 0}
  validates :minimum_abstract_length, presence: true
  validates :maximum_abstract_length, presence: true
  validate :length_step

  alias_attribute :name, :title

  LENGTH_STEP = 15

  ##
  # Return the length in timestamp format (HH:MM)
  #
  def length_timestamp
    [length / 60, length % 60].map { |t| t.to_s.rjust(2, '0') }.join(':')
  end

  private

  ##
  # Check if length is multiple of LENGTH_STEP. Used as validation.
  #
  def length_step
    errors.add(:length, "must be multiple of #{LENGTH_STEP}") if length % LENGTH_STEP != 0
  end
end
