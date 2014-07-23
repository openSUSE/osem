# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :photo do
    picture_file_name 'rails.png'
    picture_content_type 'image/png'
    picture_file_size '1024'
    picture_updated_at { DateTime.now }
    description 'Lorem Ipsum Dolor'
    conference
  end
end
