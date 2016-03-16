# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registration do
    user
    conference
    arrival 3.days.ago
  end
end
