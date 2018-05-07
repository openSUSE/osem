# frozen_string_literal: true

FactoryGirl.define do
  factory :subscription do
    user
    conference
  end

end
