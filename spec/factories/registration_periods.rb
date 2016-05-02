# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registration_period do
    start_date { 3.days.ago }
    end_date { 5.days.from_now }
  end
end
