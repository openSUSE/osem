# frozen_string_literal: true

require 'spec_helper'

describe FullCalendarFormatter do
  let!(:room1) { create(:room) }
  let!(:room2) { create(:room) }
  let!(:rooms) { [room1, room2] }
  let!(:event_schedule1) { create(:event_schedule, room: room1) }
  let!(:event_schedule2) { create(:event_schedule, room: room2) }
  let!(:event_schedules) { [event_schedule1, event_schedule2] }

  describe 'JSON formatting for FullCalendar' do
    it 'translates rooms to resources' do
      resources = described_class.rooms_to_resources(rooms)
      expected_json = [
        {
          id:    room1.guid,
          title: room1.name
        },
        {
          id:    room2.guid,
          title: room2.name
        }
      ].to_json
      expect(resources).to eq(expected_json)
    end

    it 'translates event schedules to resources' do
      resources = described_class.event_schedules_to_resources(event_schedules)
      expected_json = [
        {
          id:         event_schedule1.event.guid,
          title:      event_schedule1.event.title,
          start:      event_schedule1.start_time,
          end:        event_schedule1.end_time,
          resourceId: room1.guid
        },
        {
          id:         event_schedule2.event.guid,
          title:      event_schedule2.event.title,
          start:      event_schedule2.start_time,
          end:        event_schedule2.end_time,
          resourceId: room2.guid
        }
      ].to_json
      expect(resources).to eq(expected_json)
    end
  end
end
