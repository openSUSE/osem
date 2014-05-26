FactoryGirl.define do
  factory :person do
    first_name 'Example first_name'
    last_name 'Example last_name'
    sequence(:email) { |n| "example#{n}@example.com" }
    featured true
    user
  end
end
