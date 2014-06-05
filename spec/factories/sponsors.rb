# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sponsor do
    name 'Example sponsor'
    website_url 'http://www.example.com'
    description 'Lorem Ipsum Dolor'
    sponsorship_level
    conference
  end
end
