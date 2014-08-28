class EventsRegistration < ActiveRecord::Base
  attr_accessible :registration_id, :event_id

  belongs_to :registration
  belongs_to :event
end
