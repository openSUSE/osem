# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sponsor do
    name { Faker::Company.name }
    website_url { Faker::Internet.url }
    description { CGI.escapeHTML(Faker::Lorem.paragraph) }

    sponsorship_level

    after(:create) do |sponsor|
      logo = "#{1 + rand(13)}.png"
      uploader = PictureUploader.new(sponsor, :picture)
      File.open("spec/support/logos/#{logo}") { |f| uploader.store!(f) }
      sponsor.logo_file_name = logo.to_s
      sponsor.save
    end
  end
end
