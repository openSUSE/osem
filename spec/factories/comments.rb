# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    body 'Most interresting comment ever, created by a girl.'
    user
    association :commentable, factory: :event
  end
end
