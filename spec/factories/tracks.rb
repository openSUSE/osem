FactoryGirl.define do
  factory :track do
    name { Faker::Commerce.department(2, true) }
    description { Faker::Lorem.sentence }
    color { Faker::Color.hex_color }
    short_name { SecureRandom.urlsafe_base64(5) }
    program
  end
end
