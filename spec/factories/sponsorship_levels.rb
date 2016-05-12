# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sponsorship_level do
    title { Faker::Lorem.word }

    conference
  end
end
