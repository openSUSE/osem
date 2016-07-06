FactoryGirl.define do
  factory :payment do
    first_name { "#{Faker::Hipster.word} abc" }
    last_name { "#{Faker::Hipster.word} xyz" }
    credit_card_number { '4242424242424242' }
    card_verification_value { '123' }
    expiration_month { '06' }
    expiration_year { Date.current.year + 2 }
    amount { '10' }
  end
end
