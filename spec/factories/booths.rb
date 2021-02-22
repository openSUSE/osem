# frozen_string_literal: true

# == Schema Information
#
# Table name: booths
#
#  id                     :bigint           not null, primary key
#  description            :text
#  logo_link              :string
#  reasoning              :text
#  state                  :string
#  submitter_relationship :text
#  title                  :string
#  website_url            :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  conference_id          :integer
#
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
  end
end
