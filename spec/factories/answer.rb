# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :answer do
    title 'I do'

    factory :first_answer do
      title 'First Answer'
    end

    factory :second_answer do
      title 'Second Answer'
    end

    factory :answer_yes do
      title 'Yes'
    end

    factory :answer_no do
      title 'No'
    end
  end
end
