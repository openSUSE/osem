# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question do
    title 'blah'
    question_type_id 1
    question_type
    global false
    after(:build) do |question|
      question.answers << build(:answer)
      question.conferences << build(:conference)
    end
  end
end
