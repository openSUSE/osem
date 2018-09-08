# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    user
    conference
    status { 'unpaid' }
  end
end
