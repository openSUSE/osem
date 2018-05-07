# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :events_registration do
    event
    registration
  end
end
