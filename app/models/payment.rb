class Payment < ActiveRecord::Base
  has_many :ticket_purchases
  belongs_to :user
  belongs_to :conference

  attr_accessor :credit_card_number
  attr_accessor :credit_card_type
  attr_accessor :card_verification_value
  attr_accessor :expiration_month
  attr_accessor :expiration_year

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :credit_card_number, presence: true
  validates :card_verification_value, presence: true, length: { minimum: 3, maximum: 4 }
  validates :expiration_month, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 12 }
  validates :expiration_year, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }

  enum status: {
    unpaid: 0,
    success: 1,
    failure: 2
  }

  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      first_name:          first_name,
      last_name:           last_name,
      number:              credit_card_number,
      month:               expiration_month,
      year:                expiration_year,
      verification_value:  card_verification_value
    )
  end

  def purchase(user, conference, price_in_cents)
    gateway_response = begin
      GATEWAY.purchase(price_in_cents, credit_card, currency: conference.tickets.first.price_currency)
    rescue
      ActiveMerchant::Billing::Response.new(false, 'Unable to receive any response from the payment gateway.')
    end


    if gateway_response.success?
      self.user_id = user.id
      self.conference_id = conference.id
      self.last4 = credit_card.display_number
      self.authorization_code = gateway_response.authorization
      self.status = 'success'
    else
      errors.add(:base, gateway_response.message)
      self.status = 'failure'
    end

    success?
  end
end

