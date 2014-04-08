# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :conference do
	title "The dog and pony show"
	short_title "dps14"
	social_tag "dps14"
	timezone "Amsterdam"
	contact_email "admin@example.com"
	start_date Date.today
	end_date Date.tomorrow
  end
end
