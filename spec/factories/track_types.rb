# frozen_string_literal: true

FactoryBot.define do
  factory :track_type do
    title { 'Example Track Type' }
    description { 'test description' }
    program
  end
end
