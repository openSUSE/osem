# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :program do
    schedule_public false
    schedule_fluid false
    conference

    trait :with_cfp do
      after(:create) { |program| create(:cfp, program: program) }
    end
  end
end
