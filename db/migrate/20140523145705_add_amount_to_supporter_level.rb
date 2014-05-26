class AddAmountToSupporterLevel < ActiveRecord::Migration
  def change
    add_column :supporter_levels, :amount, :float
  end
end
