# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event_type do
    title 'Example Event Type'
    length 30
    minimum_abstract_length 0
    maximum_abstract_length 500
    color '#ffffff'
    program
  end

end
