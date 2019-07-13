class AddPriceCurrencyToConferences < ActiveRecord::Migration[5.1]
  def change
    add_column :conferences, :price_currency, :string, default: "USD"
  end
end
