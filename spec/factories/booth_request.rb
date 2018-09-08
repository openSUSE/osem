# frozen_string_literal: true

FactoryBot.define do
  factory :booth_request do
    booth
    user
    role { 'responsible' }

  end
end
