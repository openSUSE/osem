# frozen_string_literal: true

class AddPaymentIdToTicketPurchases < ActiveRecord::Migration[4.2]
  def change
    add_column :ticket_purchases, :payment_id, :integer
  end
end
