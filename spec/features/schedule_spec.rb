# frozen_string_literal: true

require 'spec_helper'

def expect_scheduled(event, time)
  visit admin_conference_program_event_path(event.conference.short_title, event)
  if time
    date = event.conference.start_date.strftime('%F')
    expect(page).to have_text("Scheduled time #{date} #{time} #{event.conference.timezone}")
  else
    expect(page).to have_no_text('Scheduled')
  end
end

def move(event, to:)
  draggable = find("#event-#{event.id}.ui-draggable")
  droppable = find("#schedule-room-#{to[0].guid}-#{to[1]}-#{to[2]}.ui-droppable")
  wait_for_ajax { draggable.drag_to droppable }
end

def remove(event)
  button = find("#event-#{event.id} .schedule-event-delete-button")
  wait_for_ajax { button.click }
end

feature Schedule do
  let(:venue) { create(:venue) }
  let(:conference) { create(:conference, venue: venue) }
  let!(:room) { create(:room, venue: venue) }
  let!(:event) { create(:event, program: conference.program, state: 'confirmed') }

  context 'as an organizer' do
    let(:organizer) { create(:organizer, resource: conference) }

    before :each do
      sign_in organizer
    end

    scenario 'create a schedule', js: true do
      expect_scheduled event, nil

      visit admin_conference_schedules_path(conference)
      click_on 'Add Schedule'
      move event, to: [room, 9, 30]
      wait_for_ajax { switch conference.short_title, to: true }

      expect_scheduled event, '09:30'
    end

    scenario 'reschedule an event', js: true do
      create(:event_schedule, event: event, room: room)
      expect_scheduled event, '09:00'

      visit admin_conference_schedule_path(conference, conference.program.selected_schedule)
      move event, to: [room, 12, 15]

      expect_scheduled event, '12:15'
    end

    scenario 'unschedule an event', js: true do
      create(:event_schedule, event: event, room: room)
      expect_scheduled event, '09:00'

      visit admin_conference_schedule_path(conference, conference.program.selected_schedule)
      remove event

      expect_scheduled event, nil
    end
  end
end
