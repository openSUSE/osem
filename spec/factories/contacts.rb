# frozen_string_literal: true

FactoryBot.define do
  factory :contact do
    social_tag { SecureRandom.urlsafe_base64(4) }
    email { Faker::Internet.email }
    sponsor_email { Faker::Internet.email }
    facebook { Faker::Internet.url(host: 'facebook.com') }
    googleplus { Faker::Internet.url(host: 'plus.google.com') }
    twitter { Faker::Internet.url(host: 'twitter.com') }
    instagram { Faker::Internet.url(host: 'instagram.com') }

    conference
  end
end
