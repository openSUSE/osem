# frozen_string_literal: true

FactoryGirl.define do
  factory :survey_submission do
    user
    survey
  end
end
