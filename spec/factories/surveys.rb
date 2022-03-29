# frozen_string_literal: true

FactoryBot.define do
  factory :survey do
    title { 'This is my survey' }

    factory :conference_survey do
      association :surveyable, factory: :conference
    end

    factory :registration_survey do
      association :surveyable, factory: :registration
    end
  end
end
