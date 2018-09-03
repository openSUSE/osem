# frozen_string_literal: true

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
