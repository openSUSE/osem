# frozen_string_literal: true

class CreateDietaryChoicesTable < ActiveRecord::Migration
  def up
    create_table :dietary_choices do |t|
      t.references :conference
      t.string :title, null: false
      t.timestamps
    end
  end

  def down
    drop_table :dietary_choices
  end
end
