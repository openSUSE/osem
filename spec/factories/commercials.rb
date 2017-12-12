# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :commercial do
    sequence(:url) { |n| "https://www.youtube.com/watch?v=BTTygyxuGj#{n}" }

    factory :conference_commercial do
      association :commercialable, factory: :conference
    end

    factory :event_commercial do
      association :commercialable, factory: :event
    end
  end
end
