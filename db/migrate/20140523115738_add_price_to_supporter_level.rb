class AddPriceToSupporterLevel < ActiveRecord::Migration
  def change
    add_money :supporter_levels, :price
  end
end
