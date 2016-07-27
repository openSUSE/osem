class AddPaymentIdToTicketPurchases < ActiveRecord::Migration
  def change
    add_column :ticket_purchases, :payment_id, :integer
  end
end
