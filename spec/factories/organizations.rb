# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :organization do
    name 'Example organization'
    sequence(:email) { |n| "example#{n}@example.com" }
    website_url 'www.esxample.com'
    description 'Lorem Ipsum Dolor'
    phone_number '900099009'
  end
end
