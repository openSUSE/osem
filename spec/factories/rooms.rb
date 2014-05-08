# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :room do
    name 'Example Room'
    size 4
    conference

    factory :room_for_100 do
      name 'Room for 100'
      size 100
    end
  end
end
