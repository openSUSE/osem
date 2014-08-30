# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :conference do
    title 'The dog and pony show'
    sequence(:short_title) { |n| "dps#{n}14" }
    timezone 'Amsterdam'
    start_date { Date.today }
    end_date { 6.days.from_now }
    venue
  end
end
