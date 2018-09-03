# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    user
    conference
  end

end
