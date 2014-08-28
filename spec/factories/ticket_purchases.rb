FactoryGirl.define do
  factory :ticket_purchase do
    user
    conference
    ticket
    quantity 10
  end
end
