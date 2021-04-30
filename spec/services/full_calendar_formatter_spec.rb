# frozen_string_literal: true

require 'spec_helper'

describe FullCalendarFormatter do
  let!(:room1) { create(:room) }
  let!(:room2) { create(:room) }
  let!(:rooms) { [room1, room2] }
  let!(:conference) { create(:full_conference) }
  let!(:program) { conference.program }
  let!(:selected_schedule) { create(:schedule, program: program) }
  let!(:event_type1) { create(:event_type, color: '#ffffff') }
  let!(:event1) do
    program.update_attributes!(selected_schedule: selected_schedule)
    create(:event, program: program, event_type: event_type1)
  end
  let!(:event_schedule1) { create(:event_schedule, event: event1, schedule: selected_schedule, room: room1) }
  let!(:event_type2) { create(:event_type, color: '#000000') }
  let!(:event2) do
    program.update_attributes!(selected_schedule: selected_schedule)
    create(:event, program: program, room: room2, event_type: event_type2)
  end
  let!(:event_schedule2) { create(:event_schedule, event: event2, schedule: selected_schedule, room: room2) }
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
          id:              event_schedule1.event.guid,
          title:           event_schedule1.event.title,
          start:           event_schedule1.start_time,
          end:             event_schedule1.end_time,
          resourceId:      room1.guid,
          url:             Rails.application.routes.url_helpers.conference_program_proposal_path(conference.short_title, event1.id),
          backgroundColor: event1.event_type.color,
          textColor:       'black'
        },
        {
          id:              event_schedule2.event.guid,
          title:           event_schedule2.event.title,
          start:           event_schedule2.start_time,
          end:             event_schedule2.end_time,
          resourceId:      room2.guid,
          url:             Rails.application.routes.url_helpers.conference_program_proposal_path(conference.short_title, event2.id),
          backgroundColor: event2.event_type.color,
          textColor:       'white'
        }
      ].to_json
      expect(resources).to eq(expected_json)
    end
  end
end
