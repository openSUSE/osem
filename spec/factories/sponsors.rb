# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
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
