FactoryGirl.define do
  factory :booth do
    title { Faker::Hipster.sentence }
    description { Faker::Lorem.paragraph }
    reasoning { Faker::Lorem.paragraph }
    website_url { Faker::Internet.url }
    submitter_relationship { Faker::Lorem.paragraph }

    conference

    after(:build) do |booth|
      booth.responsibles << create(:booth_request).user
    end

  end
end
