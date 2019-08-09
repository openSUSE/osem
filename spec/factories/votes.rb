# frozen_string_literal: true

FactoryBot.define do
  factory :vote do
    user
    rating { 1 }

    association :votable, factory: :event

  end
end
