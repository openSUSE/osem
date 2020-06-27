# frozen_string_literal: true

class CreateBoothRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :booth_requests do |t|
      t.references :booth, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :role

      t.timestamps null: false
    end
  end
end
