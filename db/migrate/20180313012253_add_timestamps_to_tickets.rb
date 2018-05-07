# frozen_string_literal: true

class AddTimestampsToTickets < ActiveRecord::Migration[5.0]
  def up
    add_column :tickets, :created_at, :datetime
    add_column :tickets, :updated_at, :datetime
    EventType.update_all(created_at: Time.now, updated_at: Time.now)
  end

  def down
    remove_column :tickets, :created_at
    remove_column :tickets, :updated_at
  end
end
