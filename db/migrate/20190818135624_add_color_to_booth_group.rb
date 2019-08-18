class AddColorToBoothGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :booth_groups, :color, :string, default: '#000000'
  end
end
