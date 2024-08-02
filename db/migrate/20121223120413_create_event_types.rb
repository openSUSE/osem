# frozen_string_literal: true

class CreateEventTypes < ActiveRecord::Migration[5.0]
  def up
    create_table :event_types do |t|
      t.references :conference
      t.string :title, null: false
      t.integer :length, default: 30
    end
  end

  def down
    drop_table :event_types
  end
end
