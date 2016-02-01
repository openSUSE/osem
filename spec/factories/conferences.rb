# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :conference do
    title 'The dog and pony show'
    sequence(:short_title) { |n| "dps#{n}14" }
    timezone 'Amsterdam'
    start_date { Date.today }
    end_date { 6.days.from_now }
    registration_limit 0

    factory :full_conference do
      splashpage
      registration_period

      after :create do |conference|
        create(:venue, conference_id: conference.id)
        conference.commercials << create(:conference_commercial, commercialable: conference)
        conference.campaigns << create(:campaign, conference: conference)
        conference.targets << create(:target, conference: conference)
        conference.questions << create(:question, conference_id: conference.id)
        conference.lodgings << create(:lodging, conference: conference)
        conference.sponsors << create(:sponsor, conference: conference)
        conference.sponsorship_levels << create(:sponsorship_level, conference: conference)
        conference.tickets << create(:ticket, conference: conference)
      end
    end
  end
end
