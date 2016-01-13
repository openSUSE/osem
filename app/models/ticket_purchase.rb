class TicketPurchase < ActiveRecord::Base
  belongs_to :ticket
  belongs_to :user
  belongs_to :conference

  validates :ticket_id, :user_id, :conference_id, :quantity, presence: true

  validates_numericality_of :quantity, greater_than: 0

  validates_uniqueness_of :user_id,
                          scope: :ticket_id,
                          message: 'already bought this ticket!'

  delegate :title, to: :ticket
  delegate :description, to: :ticket
  delegate :price, to: :ticket
  delegate :price_cents, to: :ticket
  delegate :price_currency, to: :ticket

  def self.purchase(conference, user, purchases)
    errors = []
    ActiveRecord::Base.transaction do
      conference.tickets.each do |ticket|
        quantity = purchases[ticket.id.to_s].to_i
        # if the user bought the ticket, just update the quantity
        if ticket.bought?(user)
          purchase = update_quantity(conference, quantity, ticket, user)
        else
          purchase = purchase_ticket(conference, quantity, ticket, user)
        end

        if purchase && !purchase.save
          errors.push(purchase.errors.full_messages)
        end
      end
    end
    errors.join('. ')
  end

  def self.purchase_ticket(conference, quantity, ticket, user)
    purchase = new(ticket_id: ticket.id,
                   conference_id: conference.id,
                   user_id: user.id,
                   quantity: quantity) if quantity > 0
    purchase
  end

  def self.update_quantity(conference, quantity, ticket, user)
    purchase = TicketPurchase.where(ticket_id: ticket.id,
                                    conference_id: conference.id,
                                    user_id: user.id).first

    purchase.quantity = quantity if quantity > 0
    purchase
  end
end
