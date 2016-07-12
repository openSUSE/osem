class EventSchedule < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :event
  belongs_to :room

  def room_guid
    room.try(:guid)
  end
end
