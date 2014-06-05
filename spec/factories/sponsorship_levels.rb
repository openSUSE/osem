# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sponsorship_level do
    title 'Platin'
    donation_amount '$100,000'
    conference
  end
end
