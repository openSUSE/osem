# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question_type do
    title 'A type for question'

    factory :yes_no do
      title 'Yes/No'
    end

    factory :single_choice do
      title 'Single Choice'
    end

    factory :multiple_choice do
      title 'Multiple Choice'
    end
  end
end
