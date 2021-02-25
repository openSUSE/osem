# frozen_string_literal: true

# == Schema Information
#
# Table name: tickets
#
#  id                  :bigint           not null, primary key
#  description         :text
#  price_cents         :integer          default(0), not null
#  price_currency      :string           default("USD"), not null
#  registration_ticket :boolean          default(FALSE)
#  title               :string           not null
#  visible             :boolean          default(TRUE)
#  created_at          :datetime
#  updated_at          :datetime
#  conference_id       :integer
#
class Ticket < ApplicationRecord
  belongs_to :conference
  has_many :ticket_purchases, dependent: :destroy
  has_many :buyers, -> { distinct }, through: :ticket_purchases, source: :user

  has_paper_trail meta:   { conference_id: :conference_id },
                  ignore: %i[updated_at]

  monetize :price_cents, with_model_currency: :price_currency

  scope :for_registration, -> { where(registration_ticket: true) }

  # This validation is for the sake of simplicity.
  # If we would allow different currencies per conference we also have to handle convertions between currencies!
  validate :tickets_of_conference_have_same_currency

  validates :price_cents, :price_currency, :title, presence: true

  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }

  scope :visible, -> { where(visible: true) }

  def bought?(user)
    buyers.include?(user)
  end

  def tickets_paid(user)
    paid_tickets    = quantity_bought_by(user, paid: true)
    unpaid_tickets  = quantity_bought_by(user, paid: false)
    "#{paid_tickets}/#{paid_tickets + unpaid_tickets}"
  end

  def quantity_bought_by(user, paid: false)
    ticket_purchases.by_user(user).where(paid: paid).sum(:quantity)
  end

  def unpaid?(user)
    ticket_purchases.unpaid.by_user(user).present?
  end

  def total_price(user, paid: false)
    quantity_bought_by(user, paid: paid) * price
  end

  def self.total_price(conference, user, paid: false)
    tickets = Ticket.where(conference_id: conference.id)
    result = nil
    begin
      tickets.each do |ticket|
        price = ticket.total_price(user, paid: paid)
        if result
          result += price unless price.zero?
        else
          result = price
        end
      end
    rescue Money::Bank::UnknownRate
      result = Money.new(-1, 'USD')
    end
    result ? result : Money.new(0, 'USD')
  end

  def self.total_price_user(conference, user, paid: false)
    tickets = TicketPurchase.where(conference: conference, user: user, paid: paid)
    tickets.inject(0){ |sum, ticket| sum + (ticket.amount_paid * ticket.quantity) }
  end

  def tickets_turnover_total(id)
    ticket = Ticket.find(id)
    return Money.new(0, 'USD') unless ticket

    sum = ticket.ticket_purchases.paid.total
    Money.new(sum, ticket.price_currency)
  end

  def tickets_sold
    ticket_purchases.paid.sum(:quantity)
  end

  private

  def tickets_of_conference_have_same_currency
    tickets = Ticket.where(conference_id: conference_id)
    return if tickets.count.zero? || (tickets.count == 1 && self == tickets.first)

    unless tickets.all?{|t| t.price_currency == price_currency }
      errors.add(:price_currency, 'is different from the existing tickets of this conference.')
    end
  end
end
