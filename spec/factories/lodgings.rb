# frozen_string_literal: true

# == Schema Information
#
# Table name: lodgings
#
#  id                 :bigint           not null, primary key
#  description        :text
#  name               :string
#  photo_content_type :string
#  photo_file_name    :string
#  photo_file_size    :integer
#  photo_updated_at   :datetime
#  picture            :string
#  website_link       :string
#  created_at         :datetime
#  updated_at         :datetime
#  conference_id      :integer
#

FactoryBot.define do
  factory :lodging do
    name { "#{Faker::App.name} Hotel" }
    description { Faker::Lorem.paragraph }
    website_link { Faker::Internet.url }
  end

  factory :lodging_xss, parent: :lodging do
    description { '<div id="divInjectedElement"></div>' }
  end
end
