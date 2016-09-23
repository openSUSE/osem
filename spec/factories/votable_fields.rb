FactoryGirl.define do
  factory :votable_field do
    title { Faker::Lorem.word }
    votable_type { 'Event' }
    conference
  end
end
