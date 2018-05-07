# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registration do
    user
    conference
  end
end
