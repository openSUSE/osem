# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :campaign do
    name { 'Test Campaign' }
    utm_campaign { 'testcampaign' }
    conference
  end
end
