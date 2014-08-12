# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :audience do
    registration_start_date { 3.days.from_now }
    registration_end_date { 5.days.from_now }
    registration_description 'Lorem ipsum dolorem ...'
  end
end
