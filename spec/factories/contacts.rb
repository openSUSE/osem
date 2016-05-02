FactoryGirl.define do
  factory :contact do
    social_tag { SecureRandom.urlsafe_base64(4) }
    email { Faker::Internet.email }
    sponsor_email { Faker::Internet.email }
    facebook { Faker::Internet.url('facebook.com') }
    googleplus { Faker::Internet.url('plus.google.com') }
    twitter { Faker::Internet.url('twitter.com') }
    instagram { Faker::Internet.url('instagram.com') }

    conference
  end
end
