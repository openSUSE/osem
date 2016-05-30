FactoryGirl.define do
  factory :ticket do
    title { "#{Faker::Hipster.word} Ticket" }
    price_cents 1000
    price_currency 'USD'
    payment_mode 'Online'
  end
end
