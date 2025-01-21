# frozen_string_literal: true

class CreateResourcesTable < ActiveRecord::Migration[5.0]
  def change
    create_table :resources do |t|
      t.string :name
      t.text :description
      t.integer :quantity
      t.integer :used, default: 0
      t.references :conference
    end
  end
end
