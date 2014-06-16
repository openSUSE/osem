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
    make_conference_public true
    venue
  end
end
