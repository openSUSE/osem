# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :question_type do
    title { 'Multiple Choice' }
  end
end
