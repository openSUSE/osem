# frozen_string_literal: true

# == Schema Information
#
# Table name: conferences
#
#  id                 :bigint           not null, primary key
#  booth_limit        :integer          default(0)
#  color              :string
#  custom_css         :text
#  custom_domain      :string
#  description        :text
#  end_date           :date             not null
#  end_hour           :integer          default(20)
#  events_per_week    :text
#  guid               :string           not null
#  logo_file_name     :string
#  picture            :string
#  registration_limit :integer          default(0)
#  revision           :integer          default(0), not null
#  short_title        :string           not null
#  start_date         :date             not null
#  start_hour         :integer          default(9)
#  ticket_layout      :integer          default("portrait")
#  timezone           :string           not null
#  title              :string           not null
#  use_vdays          :boolean          default(FALSE)
#  use_volunteers     :boolean
#  use_vpositions     :boolean          default(FALSE)
#  created_at         :datetime
#  updated_at         :datetime
#  organization_id    :integer
#
# Indexes
#
#  index_conferences_on_organization_id  (organization_id)
#

FactoryBot.define do
  factory :conference do
    title { Faker::Book.title }
    short_title { SecureRandom.urlsafe_base64(4) }
    timezone { Faker::Address.time_zone }
    start_date { Time.zone.today }
    end_date { 6.days.from_now }
    start_hour { 9 }
    end_hour { 20 }
    registration_limit { 0 }
    ticket_layout { 'portrait' }
    description { Faker::Hipster.paragraph }
    organization
    color { '#FFFFFF' }
    after(:create) do |conference|
      Role.where(name: 'organizer', resource: conference).first_or_create(description: 'For the organizers of the conference (who shall have full access)')
      Role.where(name: 'cfp', resource: conference).first_or_create(description: 'For the members of the CfP team')
      Role.where(name: 'info_desk', resource: conference).first_or_create(description: 'For the members of the Info Desk team')
      Role.where(name: 'volunteers_coordinator', resource: conference).first_or_create(description: 'For the people in charge of volunteers')
    end

    factory :full_conference do
      association :splashpage, factory: :full_splashpage
      registration_period
      venue

      after :create do |conference|
        conference.commercials << create(:conference_commercial, commercialable: conference)

        # Contact/Program is created by Conference callbacks
        conference.contact.destroy
        conference.contact = create(:contact, conference: conference)
        conference.program.update_attributes(schedule_public: true)

        create(:cfp, program: conference.program)
        create_list(:track, 2, program: conference.program)
        create_list(:ticket, 3, conference: conference)
        create_list(:room, 3, venue: conference.venue)
        create_list(:lodging, 4, conference: conference)

        create_list(:sponsorship_level, 3, conference: conference)
        create(:sponsor, sponsorship_level: conference.sponsorship_levels.first, conference: conference)
        create_list(:sponsor, 2, sponsorship_level: conference.sponsorship_levels.second, conference: conference)
        create_list(:sponsor, 3, sponsorship_level: conference.sponsorship_levels.third, conference: conference)

        create(:question, conferences: [conference])

        # Logo...
        File.open('spec/support/logos/OSEM.jpg') do |file|
          conference.picture = file
        end
        conference.save!
      end
    end
  end
end
