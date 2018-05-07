# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :qanswer do
    question
    answer
  end
end
