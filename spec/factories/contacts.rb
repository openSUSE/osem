# frozen_string_literal: true

# == Schema Information
#
# Table name: contacts
#
#  id            :bigint           not null, primary key
#  blog          :string
#  email         :string
#  facebook      :string
#  googleplus    :string
#  instagram     :string
#  mastodon      :string
#  social_tag    :string
#  sponsor_email :string
#  twitter       :string
#  youtube       :string
#  created_at    :datetime
#  updated_at    :datetime
#  conference_id :integer
#
FactoryBot.define do
  factory :contact do
    social_tag { SecureRandom.urlsafe_base64(4) }
    email { Faker::Internet.email }
    sponsor_email { Faker::Internet.email }
    facebook { Faker::Internet.url('facebook.com') }
    googleplus { Faker::Internet.url('plus.google.com') }
    twitter { Faker::Internet.url('twitter.com') }
    instagram { Faker::Internet.url('instagram.com') }

    conference
  end
end
