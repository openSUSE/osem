# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) {|n|'name#{n}@example.com'}
    password 'changeme'
    password_confirmation 'changeme'
    confirmed_at Time.now
  end
end
