# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| 'name#{n}@example.com' }
    password 'changeme'
    password_confirmation 'changeme'
    confirmed_at Time.now
  end
  factory :admin, class: User do
   	sequence(:email) { |n| 'gopesh#{n}@exampleco.in' }
    password 'changeme'
    password_confirmation 'changeme'
    confirmed_at Time.now
    after(:create) { |user| user.role_ids = [3] }
  end
end
