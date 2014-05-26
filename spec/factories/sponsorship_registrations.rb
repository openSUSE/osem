# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sponsorship_registration do
    name 'Example Person'
    sequence(:email_id) { |n| "example#{n}@example.com" }
    contact_no '90000000000'
    amount_donated '$1,00,000'
    method_of_donation 'Cheque'
    conference
    sponsorship_level
    organization
    after(:build) do |sponsorship_registration|
      sponsorship_registration.sponsorship_level =
        build(:sponsorship_level,
              conference: sponsorship_registration.conference)
    end
  end
end
