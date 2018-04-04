# frozen_string_literal: true

FactoryGirl.define do
  factory :ticket_purchase do
    user
    conference
    ticket
    quantity 10
    factory :paid_ticket_purchase do
      after(:build) do |ticket_purchase|
        payment = create(:payment)
        ticket_purchase.pay(payment)
      end
    end
  end
end
