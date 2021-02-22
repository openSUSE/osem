# frozen_string_literal: true

# == Schema Information
#
# Table name: ticket_purchases
#
#  id            :bigint           not null, primary key
#  amount_paid   :float            default(0.0)
#  paid          :boolean          default(FALSE)
#  quantity      :integer          default(1)
#  week          :integer
#  created_at    :datetime
#  conference_id :integer
#  payment_id    :integer
#  ticket_id     :integer
#  user_id       :integer
#
FactoryBot.define do
  factory :ticket_purchase do
    user
    conference
    ticket
    quantity { 10 }
    factory :paid_ticket_purchase do
      after(:build) do |ticket_purchase|
        payment = create(:payment)
        ticket_purchase.pay(payment)
      end
    end
  end
end
