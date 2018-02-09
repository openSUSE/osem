# frozen_string_literal: true

FactoryGirl.define do
  factory :survey_reply do
    user
    survey_question
  end
end
