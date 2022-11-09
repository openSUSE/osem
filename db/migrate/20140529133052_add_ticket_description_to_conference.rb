# frozen_string_literal: true

class AddTicketDescriptionToConference < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :ticket_description, :text
  end
end
