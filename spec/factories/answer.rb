# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :answer do
    title 'I do'

    factory :answer1 do
      title 'First Answer'
    end

    factory :answer2 do
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
