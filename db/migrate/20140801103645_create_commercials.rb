# frozen_string_literal: true

class CreateCommercials < ActiveRecord::Migration
  def change
    create_table :commercials do |t|
      t.string :commercial_id
      t.string :commercial_type
      t.references :commercialable, polymorphic: true
      t.timestamps
    end
  end
end
