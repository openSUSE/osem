# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_settings do
    send_on_registration true
    send_on_accepted false
    send_on_rejected false
    send_on_confirmed_without_registration false
    send_on_updated_conference_dates true
    send_on_updated_conference_registration_dates true
    updated_conference_dates_subject 'Conference dates have been updated'
    updated_conference_registration_dates_subject 'Conference registration dates have been updated'
    registration_subject 'Lorem Ipsum Dolsum'
    registration_email_template 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit'
  end
end
