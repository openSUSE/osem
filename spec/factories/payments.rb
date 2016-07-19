FactoryGirl.define do
  factory :payment do
    first_name { "#{Faker::Hipster.word} abc" }
    last_name { "#{Faker::Hipster.word} xyz" }
    credit_card_number '4242424242424111'
    card_verification_value '123'
    expiration_month 6
    expiration_year { Date.current.year + 2 }
    amount 10
  end

  trait :invalid_credit_card do
    credit_card_number '4242424242424222'
  end

  trait :exception_credit_card do
    credit_card_number '4242424242424333'
  end
end

