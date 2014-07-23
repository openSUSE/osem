# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :call_for_papers do
    start_date { 1.day.ago }
    end_date { 7.days.from_now }
    description 'We call for papers'
    conference
  end
end
