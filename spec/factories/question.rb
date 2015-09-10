# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question do
    title 'Do you?'
    question_type

    factory :question_with_answers do
      title 'Which do you choose?'

      after(:build) do |question|
        question.answers << build(:answer1)
        question.answers << build(:answer2)
      end
    end

    factory :attending_with_partner do
      title 'Will you attend with a partner?'
      association :question_type, factory: :yes_no
      global true

      after(:build) do |question|
        question.answers << build(:answer_yes)
        question.answers << build(:answer_no)
      end
    end
  end
end
