# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_settings do
    send_on_registration true
    send_on_accepted false
    send_on_rejected false
    send_on_confirmed_without_registration false
    send_on_conference_dates_updated true
    send_on_conference_registration_dates_updated true
    send_on_program_schedule_public true
    send_on_cfp_dates_updated true
    conference_dates_updated_body 'Sample Conference\n New Dates: January 17 - 21 2014'
    conference_dates_updated_subject 'Conference dates have been updated'
    conference_registration_dates_updated_subject 'Conference registration dates have been updated'
    conference_registration_dates_updated_body 'Sample Conference\n New Dates: January 17 - 21 2014'
    send_on_venue_updated true
    venue_updated_subject 'Venue has been updated'
    venue_updated_body 'Venue has been Updated to Sample Location'
    registration_subject 'Lorem Ipsum Dolsum'
    registration_body 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit'
    cfp_dates_updated_subject 'Call for Papers dates have been updated'
    cfp_dates_updated_body 'Please checkout the new updates to submit your proposal for Sample Conference'
    program_schedule_public_subject 'Sample Conference Cfp schedule is Public'
    program_schedule_public_body 'Call for Papers schedule is Public.Checkout the link'
  end
end
