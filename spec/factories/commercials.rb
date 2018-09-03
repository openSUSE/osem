# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :commercial do
    sequence(:url) { |n| "https://www.youtube.com/watch?v=4VrhlyIgo3M&factory=#{n}" }

    factory :conference_commercial do
      association :commercialable, factory: :conference
    end

    factory :event_commercial do
      association :commercialable, factory: :event
    end
  end
end
