# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :event_type do
    title { 'Example Event Type' }
    length { 30 }
    description { 'This event type is an example.' }
    minimum_abstract_length { 0 }
    maximum_abstract_length { 123 }
    color { '#ffffff' }
    program
  end

end
