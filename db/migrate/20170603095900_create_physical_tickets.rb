# frozen_string_literal: true

class CreatePhysicalTickets < ActiveRecord::Migration[4.2]
  def change
    create_table :physical_tickets do |t|
      t.integer :ticket_purchase_id, null: false

      t.timestamps null: false
    end
  end
end
