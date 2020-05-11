# frozen_string_literal: true

class AddRegistrationTicketToTickets < ActiveRecord::Migration[4.2]
  def change
    add_column :tickets, :registration_ticket, :boolean, default: false
  end
end
