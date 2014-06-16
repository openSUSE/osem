# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :venue do
    name 'Suse Office'
    address 'Maxfeldstrasse 5 \n90409 Nuremberg'
    website 'www.opensuse.org'
    description 'Lorem Ipsum Dolor'
  end
end
