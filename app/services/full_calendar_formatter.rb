class FullCalendarFormatter
  def self.rooms_to_resources(rooms)
    rooms.map { |room| room_to_resource(room) }.to_json
  end

  def self.event_schedules_to_resources(event_schedules); end

  private_class_method

  def self.room_to_resource(room)
    {
      id:    room.guid,
      title: room.name
    }
  end
end
