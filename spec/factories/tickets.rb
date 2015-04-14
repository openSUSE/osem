FactoryGirl.define do
  factory :ticket do
    title 'Business Ticket'
    price_cents 1000
    price_currency 'USD'
    conference
  end
end
