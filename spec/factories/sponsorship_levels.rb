# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sponsorship_level do
    title 'Platin'
    description 'Lorem Ipsum'
    conference
  end
end
