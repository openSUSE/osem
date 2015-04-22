# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :commercial do
    url 'https://www.youtube.com/watch?v=BTTygyxuGj8'

    factory :conference_commercial do
      association :commercialable, factory: :conference
    end

    factory :event_commercial do
      association :commercialable, factory: :event
    end
  end
end
