# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :event_type do
    title 'Example Event Type'
    length 30
    minimum_abstract_length 0
    maximum_abstract_length 500
    color '#ffffff'
    program
  end

end
