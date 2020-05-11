# frozen_string_literal: true

class AddTicketLayoutToConferences < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :ticket_layout, :integer, default: 0
  end
end
