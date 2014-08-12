# Read about factories at https://github.com/thoughtbot/factory_girl
include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :photo do
    picture { fixture_file_upload(Rails.root.join('app', 'assets', 'images', 'rails.png'), 'image/png') }
    picture_file_name 'rails.png'
    picture_content_type 'image/png'
    picture_file_size '1024'
    picture_updated_at { DateTime.now }
    description 'Lorem Ipsum Dolor'
    conference
  end
end
