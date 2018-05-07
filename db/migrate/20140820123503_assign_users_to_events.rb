# frozen_string_literal: true

class AssignUsersToEvents < ActiveRecord::Migration
  class TempEvent < ActiveRecord::Base
    self.table_name = 'events'
  end

  class TempUser < ActiveRecord::Base
    self.table_name = 'users'
  end

  class TempEventUser < ActiveRecord::Base
    self.table_name = 'event_users'
    belongs_to :temp_event
    belongs_to :temp_user
  end

  def up
    user_deleted = TempUser.find_or_create_by(email: 'deleted@localhost.osem', name: 'User deleted',
                                              biography: 'Data is no longer available for deleted user.')

    TempEvent.all.each do |event|
      event_users = TempEventUser.where(event_id: event)
      if event_users.blank?
        # No users for event
        TempEventUser.create!(event_id: event.id, user_id: user_deleted.id, event_role: 'submitter')
        TempEventUser.create!(event_id: event.id, user_id: user_deleted.id, event_role: 'speaker')
      else
        # Wrong records in event_users
        event_users.each do |eu|
          event_user = TempUser.where(id: eu.user_id)
          if event_user.blank?
            eu.user_id = user_deleted.id
            eu.save!
          end
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration.new('Cannot reverse migration.')
  end
end
