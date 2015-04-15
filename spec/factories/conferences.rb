# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :conference do
    title 'The dog and pony show'
    sequence(:short_title) { |n| "dps#{n}14" }
    timezone 'Amsterdam'
    start_date { Date.today }
    end_date { 6.days.from_now }
    factory :full_conference do
      venue
      splashpage
      registration_period
      call_for_paper

      after(:build) do |conference|
        conference.commercials << build(:conference_commercial, commercialable: conference)
        conference.campaigns << build(:campaign, conference: conference)
        conference.targets << build(:target, conference: conference)
        conference.questions << build(:question, conference_id: conference.id)
        conference.lodgings << build(:lodging, conference: conference)
        conference.sponsors << build(:sponsor, conference: conference)
        conference.sponsorship_levels << build(:sponsorship_level, conference: conference)
        conference.tickets << build(:ticket, conference: conference)
      end
    end
  end
end
