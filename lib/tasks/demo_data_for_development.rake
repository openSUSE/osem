# frozen_string_literal: true

namespace :data do
  desc 'Create demo data for our local development'
  include FactoryBot::Syntax::Methods

  task surveys: :environment do
    conference = create(:full_conference, start_date: Date.current, end_date: Date.current + 1.day)
    survey_after_conference_active = create(:survey, surveyable: conference, target: :after_conference, title: 'Survey about the conference', start_date: conference.start_date - 1.day, end_date: conference.end_date + 5.days, description: 'Survey about the conference. You can already see it.')
    # survey_after_conference_inactive = create(:survey, surveyable: conference, target: :after_conference, title: 'Survey about the conference', start_date: conference.start_date + 1.day, end_date: conference.end_date + 5.days, description: 'Survey abou the conference. Not available yet!')
    # survey_on_registration = create(:survey, surveyable: conference, target: :during_registration, title: 'Survey during registation', start_date: conference.registration_period.start_date, end_date: conference.registration_period.end_date, description: 'Survey during registration.')

    create(:boolean_non_mandatory, survey: survey_after_conference_active)
    create(:boolean_mandatory, survey: survey_after_conference_active)
    create(:choice_mandatory_1_reply, survey: survey_after_conference_active)
    create(:choice_non_mandatory_1_reply, survey: survey_after_conference_active)
    create(:choice_mandatory_2_replies, survey: survey_after_conference_active)
    create(:choice_non_mandatory_2_replies, survey: survey_after_conference_active)
    create(:string_mandatory, survey: survey_after_conference_active)
    create(:string_non_mandatory, survey: survey_after_conference_active)
    create(:text_mandatory, survey: survey_after_conference_active)
    create(:text_non_mandatory, survey: survey_after_conference_active)
    create(:datetime_mandatory, survey: survey_after_conference_active)
    create(:datetime_non_mandatory, survey: survey_after_conference_active)
    create(:numeric_mandatory, survey: survey_after_conference_active)
    create(:numeric_non_mandatory, survey: survey_after_conference_active)
  end

  task test: :environment do
    def generate_program conference
      program = conference.program
      user1 = create(:user)
      user2 = create(:user)

      conference_rooms = conference.venue.rooms

      selected_schedule = create(:schedule, program: program)
      demo_schedule = create(:schedule, program: program)
      program.update_attributes!(selected_schedule: selected_schedule)

      create(:event, program: program, title: 'Demo Event', abstract: 'This is a demo event instance whose state not defined.')
      create(:event, program: program, title: 'Demo Rejected Event', state: 'rejected', abstract: 'This is demo event instance in a rejected state.')
      create(:event, program: program, title: 'Demo Unconfirmed Event', state: 'unconfirmed', abstract: 'This is a demo event instance in unconfirmed state.')
      create(:event, program: program, title: 'Demo Confirmed Unscheduled Event', state: 'confirmed', abstract: 'This is a demo event instance in a confirmed state.')

      first_scheduled_event = create(:event, program: program, title: 'first_scheduled_event', state: 'confirmed', abstract: 'This is a demo scheduled event instance.')
      second_scheduled_event = create(:event, program: program, title: 'second_scheduled_event', state: 'confirmed', abstract: 'This is a demo scheduled event instance.')
      multiple_speaker_event = create(:event, program: program, title: 'multiple_speaker_event', state: 'confirmed', abstract: 'This is a demo scheduled event instance having multiple speakers.')

      create(:event_user, event: multiple_speaker_event, user: user1, event_role: 'speaker')
      create(:event_user, event: multiple_speaker_event, user: user2, event_role: 'speaker')

      create(:event_schedule, event: first_scheduled_event, schedule: selected_schedule, start_time: conference.start_date + conference.start_hour.hours, room: conference_rooms.first)
      create(:event_schedule, event: second_scheduled_event, schedule: selected_schedule, start_time: conference.start_date + conference.start_hour.hours + 15.minutes, room: conference_rooms.second)
      create(:event_schedule, event: multiple_speaker_event, schedule: selected_schedule, start_time: conference.start_date + conference.start_hour.hours + 30.minutes, room: conference_rooms.third)
      create(:event_schedule, event: first_scheduled_event, schedule: demo_schedule, start_time: conference.start_date + conference.start_hour.hours + 15.minutes, room: conference_rooms.third)
      create(:event_schedule, event: second_scheduled_event, schedule: demo_schedule, start_time: conference.start_date + conference.start_hour.hours + 30.minutes, room: conference_rooms.third)
      create(:event_schedule, event: multiple_speaker_event, schedule: demo_schedule, start_time: conference.start_date + conference.start_hour.hours, room: conference_rooms.first)

      create(:registration, user: user1, conference: conference)
      create(:registration, user: user2, conference: conference)
    end

    # This is a full conference demo instance that will happen in the future.
    # By full conference it means all basic information about conference is already set.
    conference = create(:full_conference, title: 'Open Source Event Manager Demo Conference', short_title: 'osemdemo', start_date: 2.days.from_now, end_date: 6.days.from_now, start_hour: 8, end_hour: 20, description: 'This is a full conference demo instance happening in the future. It contains open cfp, venue/rooms, submitted talks by multiple speakers, partly confirmed talks and multiple schedules.')
    generate_program conference

    # This is a full conference demo instance that has already happened.
    # By full conference it means all basic information about conference is already set.
    # Initially end date is set 6 days from now
    # So that events can be created without any failure in validations.
    conference = create(:full_conference, title: 'Jangouts Demo Conference', short_title: 'jangouts', start_date: 7.days.ago, end_date: 6.days.from_now, start_hour: 15, end_hour: 20, description: 'This is a full conference demo instance happened in the past. It contains open cfp, venue/rooms, submitted talks by multiple speakers, partly confirmed talks and multiple schedules.')
    generate_program conference
    conference.program.cfp.update_attributes!(start_date: 4.days.ago, end_date: 2.days.ago)
    conference.update_attributes!(end_date: 1.day.ago)
    conference.registration_period.update_attributes!(start_date: 9.days.ago, end_date: 8.days.ago)

    # This is a conference that will happen in the future
    # It only has a registration period and unscheduled events
    registration_period = create(:registration_period)
    conference = create(:conference, title: 'Portus Demo Conference', short_title: 'portus', registration_period: registration_period, start_date: 3.days.from_now, end_date: 7.days.from_now, start_hour: 10, end_hour: 15, description: 'This is a demo conference instance. No information about this conference is set by default.')
    create(:event, program: conference.program, title: 'Demo Event', abstract: 'This is a demo event instance whose state not defined.')
    create(:event, program: conference.program, title: 'Demo Rejected Event', state: 'rejected', abstract: 'This is demo event instance in a rejected state.')
    create(:event, program: conference.program, title: 'Demo Unconfirmed Event', state: 'unconfirmed', abstract: 'This is a demo event instance in unconfirmed state.')
    create(:event, program: conference.program, title: 'Demo Confirmed Event', state: 'confirmed', abstract: 'This is a demo event instance in a confirmed state.')

    # This is a full conference demo instance that has already started.
    # By full conference it means all basic information about conference is already set.
    # Registration period of this conference is closed now.
    registration_period = create(:registration_period, start_date: 4.days.ago, end_date: 2.days.ago)
    conference = create(:full_conference, title: 'Yast Demo Conference', short_title: 'yast', registration_period: registration_period, start_date: 2.days.ago, end_date: 7.days.from_now, start_hour: 10, end_hour: 21, description: 'This is a full conference demo instance. Its registration period is closed.')
    generate_program conference

    # This is a full conference demo instance that will happen in the future.
    # By full conference it means all basic information about conference is already set.
    # Registration for this conference has reached its limit.
    conference = create(:full_conference, title: 'Zypper Docker  Conference', short_title: 'zypper', registration_limit: 2, start_date: 3.days.from_now, end_date: 7.days.from_now, start_hour: 7, end_hour: 19, description: 'This is a full conference demo instance. Its registrations has reached the limit.')
    generate_program conference
  end
end
