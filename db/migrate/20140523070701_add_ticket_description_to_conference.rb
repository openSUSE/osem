class AddTicketDescriptionToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :ticket_description, :text
  end
end
