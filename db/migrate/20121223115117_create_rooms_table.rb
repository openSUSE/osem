# frozen_string_literal: true

class CreateRoomsTable < ActiveRecord::Migration[5.0]
  def up
    create_table :rooms do |t|
      t.string :guid, null: false
      t.references :conference
      t.string :name, null: false
      t.integer :size
      t.boolean :public, default: true
    end
  end

  def down
    drop_table :rooms
  end
end
