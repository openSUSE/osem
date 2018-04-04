# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event_schedule do
    event
    after(:build) do |event_schedule|
      program = event_schedule.event.program
      unless (venue = program.conference.venue)
        venue = create(:venue, conference: program.conference)
      end
      (event_schedule.room = create(:room, venue: venue)) if event_schedule.room.blank?
      (event_schedule.start_time = program.conference.start_date + program.conference.start_hour.hours) if event_schedule.start_time.blank?
      if event_schedule.schedule.blank?
        if program.selected_schedule.blank?
          schedule = create(:schedule, program: program)
          program.schedules << schedule
          program.selected_schedule = schedule
          program.save!
        end
        event_schedule.schedule = program.selected_schedule
      end
    end
  end
end
