# frozen_string_literal: true

FactoryBot.define do
  factory :ticket do
    title { "#{Faker::Hipster.word} Ticket" }
    price_cents { 1000 }
    price_currency { 'USD' }
    visible { true }
    factory :registration_ticket do
      registration_ticket { true }
    end
  end
end
