# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :organization do
    title 'Example Organization'
    sequence(:email_id) { |n| "example#{n}@example.com" }
    website_url 'www.example.com'
  end
end
