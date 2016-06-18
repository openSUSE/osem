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

  validate :validate_card, on: create

  enum status: {
    unpaid: 0,
    success: 1,
    failure: 2
  }

  def credit_card
    @credit_card = ActiveMerchant::Billing::CreditCard.new(
      first_name:          first_name,
      last_name:           last_name,
      number:              credit_card_number,
      month:               expiration_month,
      year:                expiration_year,
      verification_value:  card_verification_value
    )
  end

  def validate_card
    unless credit_card.validate.empty?
      credit_card.errors.full_messages.each do |message|
        errors.add(:base, message)
      end
    end
    credit_card.validate.empty?
  end

  def price_in_cents
    (amount * 100).round
  end

  def purchase(user, conference)
    begin
      response = GATEWAY.purchase(price_in_cents, credit_card, currency: conference.tickets.first.price_currency)
    rescue
      false
    end

    unless response
      errors.add(:base, 'Unable to recieve any response')
      return false
    end
    unless response.success?
      errors.add(:base, response.message)
      self.status = 2
      return false
    end
    self.user_id = user.id
    self.conference_id = conference.id
    self.last4 = credit_card.display_number
    self.authorization_code = response.authorization
    self.status = 1
    response.success?
  end
end
