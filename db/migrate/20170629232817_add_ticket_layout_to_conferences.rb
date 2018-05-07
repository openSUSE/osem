# frozen_string_literal: true

class AddTicketLayoutToConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :ticket_layout, :integer, default: 0
  end
end
