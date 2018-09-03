# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :openid do
    provider { Faker::Internet.domain_word }
    email { Faker::Internet.email }
    uid { SecureRandom.hex }
    user
  end
end
