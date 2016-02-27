class EventType < ActiveRecord::Base
  belongs_to :program
  has_many :events, dependent: :restrict_with_error

  validates :title, presence: true
  validates :length, numericality: {greater_than: 0}
  validates :minimum_abstract_length, presence: true
  validates :maximum_abstract_length, presence: true

  alias_attribute :name, :title
end
