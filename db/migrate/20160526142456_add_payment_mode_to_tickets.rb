class AddPaymentModeToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :payment_mode, :string
  end
end
