# frozen_string_literal: true

class AddAmountPaidToTicketPurchases < ActiveRecord::Migration[4.2]
  def change
    add_column :ticket_purchases, :amount_paid, :float, default: 0
  end
end
