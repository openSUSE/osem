# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                           :bigint           not null, primary key
#  abstract                     :text
#  comments_count               :integer          default(0), not null
#  committee_review             :text
#  description                  :text
#  guid                         :string           not null
#  is_highlight                 :boolean          default(FALSE)
#  language                     :string
#  max_attendees                :integer
#  progress                     :string           default("new"), not null
#  proposal_additional_speakers :text
#  public                       :boolean          default(TRUE)
#  require_registration         :boolean
#  start_time                   :datetime
#  state                        :string           default("new"), not null
#  subtitle                     :string
#  title                        :string           not null
#  week                         :integer
#  created_at                   :datetime
#  updated_at                   :datetime
#  difficulty_level_id          :integer
#  event_type_id                :integer
#  program_id                   :integer
#  room_id                      :integer
#  track_id                     :integer
#

FactoryBot.define do
  factory :event do
    title { Faker::Hipster.sentence }
    abstract { Faker::Hipster.paragraph(2) }

    program

    after(:build) do |event|
      event.submitter = build(:submitter).user unless event.submitter # so that we don't have two submitters
      event.speakers << build(:speaker).user unless event.speakers.any?
      # set an event_type if none is passed to the factory.
      # needs to be created here because otherwise it doesn't belong to the
      # same conference as the event
      event.event_type ||= build(:event_type, program: event.program)
    end

    factory :event_full do
      difficulty_level
      after(:build) do |event|
        event.commercials << build(:event_commercial, commercialable: event)
        event.difficulty_level = build(:difficulty_level, program: event.program)
        event.track = build(:track, program: event.program)
        unless event.program.conference.venue
          create(:venue, conference: event.program.conference)
        end
        event.comment_threads << build(:comment, commentable: event)
      end

      factory :event_scheduled do
        transient do
          hour { nil }
        end

        after(:build) do |event, evaluator|
          event.state = 'confirmed'
          event.event_schedules << build(:event_schedule, event: event, start_time: evaluator.hour)
        end
      end
    end
  end

  factory :event_xss, parent: :event do
    abstract { '<div id="divInjectedElement"></div>' }
  end
end
