# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id              :bigint           not null, primary key
#  code_of_conduct :text
#  description     :text
#  name            :string           not null
#  picture         :string
#
FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "#{Faker::Company.name} #{n}" }
    description { Faker::Lorem.paragraph }

    # after(:create) do |organization|
    #   File.open("spec/support/logos/#{1 + rand(13)}.png") do |file|
    #     organization.picture = file
    #   end
    #   organization.save!
    # end
  end
end
