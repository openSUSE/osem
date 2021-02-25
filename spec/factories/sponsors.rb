# frozen_string_literal: true

# == Schema Information
#
# Table name: sponsors
#
#  id                   :bigint           not null, primary key
#  description          :text
#  logo_file_name       :string
#  name                 :string
#  picture              :string
#  website_url          :string
#  created_at           :datetime
#  updated_at           :datetime
#  conference_id        :integer
#  sponsorship_level_id :integer
#

FactoryBot.define do
  factory :sponsor do
    name { Faker::Company.name }
    website_url { Faker::Internet.url }
    description { Faker::Lorem.paragraph }

    sponsorship_level

    after(:create) do |sponsor|
      File.open("spec/support/logos/#{1 + rand(13)}.png") do |file|
        sponsor.picture = file
      end
      sponsor.save!
    end
  end
end
