# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :room do
    name { "Room #{Faker::Address.country}" }
    size 4

    venue

    factory :room_for_100 do
      name 'Room for 100'
      size 100
    end
  end
end
