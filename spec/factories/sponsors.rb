# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sponsor do
    name 'Example sponsor'
    website_url 'http://www.example.com'
    description 'Lorem Ipsum Dolor'
    sponsorship_level
    conference

    after(:create) do |sponsor|
      uploader = PictureUploader.new(sponsor, :picture)
      File.open('app/assets/images/rails.png') { |f| uploader.store!(f) }
      sponsor.logo_file_name = 'rails.png'
      sponsor.save
    end
  end
end
