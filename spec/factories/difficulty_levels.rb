# frozen_string_literal: true

FactoryBot.define do
  factory :difficulty_level do
    title { 'Example Difficulty Level' }
    description { 'Lorem Ipsum dolsum' }
    color { '#ffffff' }
    program
  end
end
