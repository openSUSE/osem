class EventType < ActiveRecord::Base
  attr_accessible :title, :length, :minimum_abstract_length, :maximum_abstract_length, :color,
                  :conference_id

  belongs_to :conference

  validates :title, presence: true
  validates :length, numericality: {greater_than: 0}
  validates :minimum_abstract_length, presence: true
  validates :maximum_abstract_length, presence: true

  alias_attribute :name, :title
end
