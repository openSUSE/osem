class AddPaymentMethodToConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :payment_method, :string, default: 'offline', null: false
  end
end
