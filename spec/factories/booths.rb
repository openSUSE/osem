# frozen_string_literal: true

FactoryBot.define do
  factory :booth do
    title { Faker::Hipster.sentence }
    description { Faker::Lorem.paragraph }
    reasoning { Faker::Lorem.paragraph }
    website_url { Faker::Internet.url }
    submitter_relationship { Faker::Lorem.paragraph }

    conference

    submitter { create(:user) }
    responsible_ids { [create(:user).id] }
    invite_responsible { 'user@example.com, example' }
  end
end
