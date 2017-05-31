FactoryGirl.define do
  factory :organization do
    name { Faker::Company.name }
    description { Faker::Lorem.paragraph }

    # after(:create) do |organization|
    #   File.open("spec/support/logos/#{1 + rand(13)}.png") do |file|
    #     organization.picture = file
    #   end
    #   organization.save!
    # end
  end
end
