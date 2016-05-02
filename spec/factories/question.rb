# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question do
    title { Faker::Lorem.sentence }
    question_type
    conferences { [create(:conference)] }
    answers { [create(:answer)] }
  end
end
