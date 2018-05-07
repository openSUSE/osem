# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :target do
    due_date { 14.days.from_now }
    target_count 100
    unit Target.units[:submissions]
    conference
  end
end
