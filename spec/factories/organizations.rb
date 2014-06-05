# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :organization do
    name 'Example organization'
    sequence(:website_url) { |n| "example#{n}@example.com" }
    description 'Lorem Ipsum Dolor'
  end
end
