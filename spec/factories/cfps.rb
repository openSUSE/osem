# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :cfp do
    start_date { 1.day.ago }
    end_date { 2.days.from_now }
    cfp_type 'events'
    description 'This is a test description'
    program
  end
end
