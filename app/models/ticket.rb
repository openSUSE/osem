class Ticket < ActiveRecord::Base
  belongs_to :conference
  has_many :ticket_purchases, dependent: :destroy
  has_many :buyers, -> { distinct }, through: :ticket_purchases, source: :user

  monetize :price_cents, with_model_currency: :price_currency

  # This validation is for the sake of simplicity.
  # If we would allow different currencies per conference we also have to handle convertions between currencies!
  validate :tickets_of_conference_have_same_currency

  validates :price_cents, :price_currency, :title, presence: true

  validates_numericality_of :price_cents, greater_than: 0

  def bought?(user)
    buyers.include?(user)
  end

  def paid?(user)
    ticket_purchases.find_by(user: user, paid: true).present?
  end

  def quantity_bought_by(user)
    result = ticket_purchases.where(user_id: user.id).first
    result ? result.quantity : 0
  end

  def total_price(user)
    quantity_bought_by(user) * price
  end

  def self.total_price(conference, user)
    tickets = Ticket.where(conference_id: conference.id)
    result = nil
    begin
      tickets.each do |ticket|
        price = ticket.total_price(user)
        if result
          result +=  price unless price.zero?
        else
          result = price
        end
      end
    rescue Money::Bank::UnknownRate
      result = Money.new(-1, 'USD')
    end
    result ? result : Money.new(0, 'USD')
  end

  def tickets_sold
    ticket_purchases.sum(:quantity)
  end

  def tickets_turnover
    tickets_sold * price
  end

  private

  def tickets_of_conference_have_same_currency
    unless Ticket.where(conference_id: conference_id).all?{|t| t.price_currency == self.price_currency }
      errors.add(:price_currency, 'is different from the existing tickets of this conference.')
    end
  end
end
