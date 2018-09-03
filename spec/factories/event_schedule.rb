# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :event_schedule do
    event
    after(:build) do |event_schedule|
      program = event_schedule.event.program
      unless (venue = program.conference.venue)
        venue = create(:venue, conference: program.conference)
      end
      (event_schedule.room = create(:room, venue: venue)) unless event_schedule.room.present?
      (event_schedule.start_time = program.conference.start_date + program.conference.start_hour.hours) unless event_schedule.start_time.present?
      unless event_schedule.schedule.present?
        unless program.selected_schedule.present?
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
