# frozen_string_literal: true

class MigratingSupporterRegistrationsToTicketUsers < ActiveRecord::Migration
  class TempSupporterRegistrations < ActiveRecord::Base
    self.table_name = 'supporter_registrations'
  end

  class TempUser < ActiveRecord::Base
    self.table_name = 'users'
  end

  class TempRegistration < ActiveRecord::Base
    self.table_name = 'registrations'
  end

  def change
    rename_column :supporter_registrations, :supporter_level_id, :ticket_id
    rename_column :supporter_registrations, :code_is_valid, :paid

    add_column :supporter_registrations, :quantity, :integer, default: 1
    add_column :supporter_registrations, :user_id, :integer

    deleted_user = TempUser.find_by(email: 'deleted@localhost.osem')

    TempSupporterRegistrations.all.each do |s|
      # Change relation from registration to user
      registration = TempRegistration.find_by(id: s.registration_id)
      if registration
        user = TempUser.find_by(id: registration.user_id)
        if user
          s.user_id = user.id
          s.save
        end
      end
      unless s.user_id
        s.user_id = deleted_user.id
        s.save
      end
    end

    # Sum up if a user has bought more than one ticket
    TempSupporterRegistrations.all.each do |s|
      sup_reg = TempSupporterRegistrations.where(
          ticket_id:     s.ticket_id,
          user_id:       s.user_id,
          conference_id: s.conference_id)
      quantity = sup_reg.count

      if quantity > 1
        # Save the amount in the first one
        s.quantity = quantity
        s.save

        # Delete the other
        sup_reg = sup_reg.where('id not in (?)', [s.id])
        sup_reg.destroy_all
      end
    end

    remove_column :supporter_registrations, :registration_id
    remove_column :supporter_registrations, :code
    remove_column :supporter_registrations, :name
    remove_column :supporter_registrations, :email
    remove_column :conferences, :use_supporter_levels

    rename_table :supporter_registrations, :ticket_purchases
  end
end
