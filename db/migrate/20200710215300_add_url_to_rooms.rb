class AddUrlToRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :url, :string
  end
end
