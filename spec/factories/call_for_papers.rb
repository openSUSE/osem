# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :call_for_paper do
    start_date { 1.day.ago }
    end_date { 6.days.from_now }
  end
end
