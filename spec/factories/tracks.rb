FactoryGirl.define do
  factory :track do
    name { Faker::Commerce.department(2, true) }
    description { Faker::Lorem.sentence }
    color { Faker::Color.hex_color }
    short_name { SecureRandom.urlsafe_base64(5) }
    state 'confirmed'
    cfp_active true
    program

    trait :self_organized do
      association :submitter, factory: :user
      state 'new'
      cfp_active false
      start_date { Date.today }
      end_date { Date.today }
      room
    end
  end
end
