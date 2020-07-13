# frozen_string_literal: true

class Payment < ApplicationRecord
  has_many :ticket_purchases
  belongs_to :user
  belongs_to :conference

  attr_accessor :stripe_customer_email
  attr_accessor :stripe_customer_token

  validates :status, presence: true
  validates :user_id, presence: true
  validates :conference_id, presence: true

  enum status: {
    unpaid:  0,
    success: 1,
    failure: 2
  }

  def amount_to_pay
    Ticket.total_price(conference, user, paid: false).cents
  end

  def stripe_description
    #"ticket purchases(#{user.username})"
    "Tickets for #{conference.title} #{user.name} #{user.email}"
  end

  def purchase
    gateway_response = Stripe::Charge.create source:        stripe_customer_token,
                                             receipt_email: stripe_customer_email,
                                             description:   stripe_description,
                                             amount:        amount_to_pay,
                                             currency:      conference.tickets.first.price_currency

    self.amount = gateway_response[:amount]
    self.last4 = gateway_response[:source][:last4]
    self.authorization_code = gateway_response[:id]
    self.status = 'success'
    true

  rescue Stripe::StripeError => error
    errors.add(:base, error.message)
    self.status = 'failure'
    false
  end
end
