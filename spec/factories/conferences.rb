# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :conference do
    title 'The dog and pony show'
    sequence(:short_title) { |n| "dps#{n}14" }
    social_tag 'dps14'
    timezone 'Amsterdam'
    contact_email 'admin@example.com'
    start_date Date.today
    end_date Date.tomorrow
    factory :conference_with_sponsorship_level do
      after(:build) do |conference|
        conference.sponsorship_levels << build(:sponsorship_level, conference: conference)
      end
    end
  end
end
