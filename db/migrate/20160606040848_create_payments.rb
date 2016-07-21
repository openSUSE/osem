class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :first_name
      t.string :last_name
      t.string :last4
      t.decimal :amount, precision: 12, scale: 3
      t.string :authorization_code
      t.integer :status, default: 0
      t.integer :user_id, null: false
      t.integer :conference_id, null: false
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps null: false
    end
  end
end
