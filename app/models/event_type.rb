class EventType < ActiveRecord::Base
  attr_accessible :title, :length, :minimum_abstract_length, :maximum_abstract_length, :color

  belongs_to :conference

  validates :length, :numericality => {:greater_than => 0} 

  alias_attribute :name, :title
end
