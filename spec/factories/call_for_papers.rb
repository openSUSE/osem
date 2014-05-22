# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :call_for_papers do
    start_date Date.today - 1
    end_date Date.today + 7
    hard_deadline Date.today + 8
    description 'We call for papers'
    conference
  end
end
