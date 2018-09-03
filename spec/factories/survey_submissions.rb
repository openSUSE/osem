# frozen_string_literal: true

FactoryBot.define do
  factory :survey_submission do
    user
    survey
  end
end
