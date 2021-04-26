class FullCalendarFormatter
  def self.rooms_to_resources(rooms)
    rooms.map { |room| room_to_resource(room) }.to_json
  end

  def self.event_schedules_to_resources(event_schedules)
    event_schedules.map { |event_schedule| event_schedule_to_resource(event_schedule) }.to_json
  end

  class << self
    private

    def room_to_resource(room)
      {
        id:    room.guid,
        title: room.name
      }
    end

    def event_schedule_to_resource(event_schedule)
      {
        id:     event_schedule.event.guid,
        title:  event_schedule.event.title,
        start:  event_schedule.start_time,
        end:    event_schedule.end_time,
        source: event_schedule.room.guid
      }
    end
  end
end
