# frozen_string_literal: true

class CreateVenueTable < ActiveRecord::Migration[5.0]
  def up
    create_table :venues do |t|
      t.string :guid
      t.string :name
      t.string :address
      t.string :website
      t.text :description
      t.string :offline_map_url
      t.string :offline_map_bounds
      t.timestamps
    end
  end

  def down
    drop_table :venues
  end
end
