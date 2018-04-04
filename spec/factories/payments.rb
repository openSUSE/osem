# frozen_string_literal: true

FactoryGirl.define do
  factory :payment do
    user
    conference
    status 'unpaid'
  end
end
