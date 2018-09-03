# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :question do
    title { Faker::Lorem.sentence }
    question_type
    conferences { [create(:conference)] }
    answers { [create(:answer)] }
  end
end
