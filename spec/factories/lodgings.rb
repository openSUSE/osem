# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lodging do
    name 'Example Hotel'
    description 'Lorem Ipsum Dolor'
    website_link 'http://www.example.com'
    conference
  end
end
