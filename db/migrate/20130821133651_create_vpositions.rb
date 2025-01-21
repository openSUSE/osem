# frozen_string_literal: true

class CreateVpositions < ActiveRecord::Migration[4.2]
  def up
    create_table :vpositions do |t|
      t.references :conference
      t.string :title, null: false
      t.text :description

      t.timestamps
    end
  end

  def down
    drop_table :vpositions
  end
end
