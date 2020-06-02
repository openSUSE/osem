class AddVisibleToTickets < ActiveRecord::Migration[5.0]
  def up
    add_column :tickets, :visible, :boolean, default: true
    Ticket.reset_column_information
    Ticket.update_all(visible: true) # rubocop:disable Rails/SkipsModelValidations
  end

  def down
    remove_column :tickets, :visible
  end
end
