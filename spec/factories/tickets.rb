FactoryGirl.define do
  factory :ticket do
    title { CGI.escapeHTML("#{Faker::Hipster.word} Ticket") }
    price_cents 1000
    price_currency 'USD'
  end
end
