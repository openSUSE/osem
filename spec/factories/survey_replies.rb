# frozen_string_literal: true

FactoryBot.define do
  factory :survey_reply do
    user
    survey_question
  end
end
