class EventType < ActiveRecord::Base
  attr_accessible :title, :length

  belongs_to :conference
end
