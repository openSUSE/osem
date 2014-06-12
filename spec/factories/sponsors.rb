# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sponsor do
    name 'Example sponsor'
    website_url 'http://www.example.com'
    description 'Lorem Ipsum Dolor'
    logo_file_name 'rails.jpg'
    logo_file_size 2000
    logo_content_type 'image/jpeg'
    logo_updated_at DateTime.current
    sponsorship_level
    conference
  end
end
