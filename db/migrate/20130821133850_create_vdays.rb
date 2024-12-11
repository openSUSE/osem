# frozen_string_literal: true

class CreateVdays < ActiveRecord::Migration[4.2]
  def up
    create_table :vdays do |t|
      t.references :conference
      t.date :day
      t.text :description

      t.timestamps
    end
  end

  def down
    drop_table :vdays
  end
end
