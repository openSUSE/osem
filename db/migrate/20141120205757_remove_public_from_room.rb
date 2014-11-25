class RemovePublicFromRoom < ActiveRecord::Migration
  def change
    remove_column :rooms, :public, :boolean, default: false
  end
end
