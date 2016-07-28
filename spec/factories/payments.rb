FactoryGirl.define do
  factory :payment do
    user
    conference
    last4 '4242'
    authorization_code '1234567890'
    amount 10
  end
end
