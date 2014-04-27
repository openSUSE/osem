FactoryGirl.define do
  factory :user do
    email 'example@example.com'
    password 'changeme'
    password_confirmation 'changeme'
    confirmed_at Time.now
  end
end
