# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_settings do
    send_on_registration true
    send_on_accepted false
    send_on_rejected false
    send_on_confirmed_without_registration false
    send_on_updated_conference_dates true
    send_on_updated_conference_registration_dates true
    send_on_call_for_papers_schedule_public true
    send_on_call_for_papers_dates_updates true
    updated_conference_dates_template 'Sample Conference\n New Dates: January 17 - 21 2014'
    updated_conference_dates_subject 'Conference dates have been updated'
    updated_conference_registration_dates_subject 'Conference registration dates have been updated'
    updated_conference_registration_dates_template 'Sample Conference\n New Dates: January 17 - 21 2014'
    send_on_venue_update true
    venue_update_subject 'Venue has been updated'
    venue_update_template 'Venue has been Updated to Sample Location'
    registration_subject 'Lorem Ipsum Dolsum'
    registration_email_template 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit'
    call_for_papers_dates_updates_subject 'Call for Papers dates have been updated'
    call_for_papers_dates_updates_template 'Please checkout the new updates to submit your proposal for Sample Conference'
    call_for_papers_schedule_public_subject 'Sample Conference Cfp schedule is Public'
    call_for_papers_schedule_public_template 'Call for Papers schedule is Public.Checkout the link'
  end
end
