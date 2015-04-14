# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :commercial do
    commercial_type 'YouTube'
    commercial_id 'test'

    factory :conference_commercial do
      association :commercialable, factory: :conference
    end

    factory :event_commercial do
      association :commercialable, factory: :event
    end
  end
end
