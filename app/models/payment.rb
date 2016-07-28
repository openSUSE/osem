class Payment < ActiveRecord::Base
  has_many :ticket_purchases
  belongs_to :user
  belongs_to :conference

  attr_accessor :stripeEmail
  attr_accessor :stripeToken

  validates :status, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :user_id, presence: true
  validates :conference_id, presence: true

  enum status: {
    unpaid: 0,
    success: 1,
    failure: 2
  }

  def amount_to_pay
    Ticket.total_price(conference, user, paid: false).cents
  end

  def purchase
    begin
      customer = Stripe::Customer.create email: stripeEmail,
                                         source: stripeToken,
                                         description: user.name

      gateway_response = Stripe::Charge.create customer: customer.id,
                                               receipt_email: stripeEmail,
                                               description: 'ticket purchases',
                                               amount: amount_to_pay,
                                               currency: conference.tickets.first.price_currency

      self.last4 = gateway_response[:source][:last4]
      self.authorization_code = gateway_response[:id]
      self.status = 'success'
      true

    rescue => error
      errors.add(:base, error.message)
      self.status = 'failure'
      false
    end
  end
end
