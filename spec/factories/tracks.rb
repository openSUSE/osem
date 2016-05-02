FactoryGirl.define do
  factory :track do
    name { CGI.escapeHTML(Faker::Commerce.department(2, true)) }
    description { Faker::Lorem.sentence }
    color { Faker::Color.hex_color }
  end
end
