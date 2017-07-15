FactoryGirl.define do
  factory :track do
    name { Faker::Commerce.department(2, true) }
    description { Faker::Lorem.sentence }
    color { Faker::Color.hex_color }
    short_name { SecureRandom.urlsafe_base64(5) }
    program

    trait :self_organized do
      association :submitter, factory: :user
      state 'new'
      cfp_active false
    end
  end
end
