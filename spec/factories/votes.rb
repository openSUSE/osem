# frozen_string_literal: true

FactoryGirl.define do
  factory :vote do
    event
    user
    rating 1
  end
end
