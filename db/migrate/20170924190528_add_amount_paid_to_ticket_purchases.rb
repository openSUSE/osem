class AddAmountPaidToTicketPurchases < ActiveRecord::Migration
  def change
    add_column :ticket_purchases, :amount_paid, :float, default: 0
  end
end
