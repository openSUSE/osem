class AddUrlToRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :url, :text
  end
end
