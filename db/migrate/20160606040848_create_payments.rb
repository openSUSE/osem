# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :last4
      t.integer :amount
      t.string :authorization_code
      t.integer :status, default: 0, null: false
      t.integer :user_id, null: false
      t.integer :conference_id, null: false

      t.timestamps null: false
    end
  end
end
