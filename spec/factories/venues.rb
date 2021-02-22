# frozen_string_literal: true

# == Schema Information
#
# Table name: venues
#
#  id              :bigint           not null, primary key
#  city            :string
#  country         :string
#  description     :text
#  guid            :string
#  latitude        :string
#  longitude       :string
#  name            :string
#  photo_file_name :string
#  picture         :string
#  postalcode      :string
#  street          :string
#  website         :string
#  created_at      :datetime
#  updated_at      :datetime
#  conference_id   :integer
#
FactoryBot.define do
  factory :venue do
    name { "#{Faker::Company.name} Office" }
    street { Faker::Address.street_address }
    city { Faker::Address.city }
    postalcode { Faker::Address.postcode }
    country { Faker::Address.country_code }
    website { Faker::Internet.url }
    description { Faker::Lorem.sentence }
  end
end
