# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :conference do
    title 'The dog and pony show'
    sequence(:short_title) { |n| "dps#{n}14" }
    social_tag 'dps14'
    timezone 'Amsterdam'
    description 'Lorem Ipsum dolsum'
    contact_email 'admin@example.com'
    start_date Date.today
    end_date Date.tomorrow
    factory :conference_with_registration do
      after(:build) do |conference|
        create(:participant_role)
        create(:admin_role)
        user = build(:user)
        conference.registrations << build(:registration,
                                          conference: conference,
                                          person: user.person)
      end
    end
  end
end
