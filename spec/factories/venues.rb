# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryBot.define do
  factory :venue do
    name { "#{Faker::Company.name} Office" }
    street { Faker::Address.street_address }
    city { Faker::Address.city }
    postalcode { Faker::Address.postcode }
    country { Faker::Address.country_code }
    website { Faker::Internet.url }
    description { Faker::Lorem.sentence }
  end
end
