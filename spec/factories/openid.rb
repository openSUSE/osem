# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :openid do
    provider { Faker::Internet.domain_word }
    email { Faker::Internet.email }
    uid { SecureRandom.hex }
    user
  end
end
