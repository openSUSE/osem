# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :venue do
    name 'Suse Office'
    street 'Maxfeldstrasse 5'
    city 'Nuremberg'
    postalcode '90489'
    country 'DE'
    website 'www.opensuse.org'
    description 'Lorem Ipsum Dolor'
  end
end
