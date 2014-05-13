# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_settings do
    send_on_registration false
    send_on_accepted false
    send_on_rejected false
    send_on_confirmed_without_registration false
  end
end
