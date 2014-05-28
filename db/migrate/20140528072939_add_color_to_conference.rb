class AddColorToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :color, :string, default: '#000000'
  end
end
