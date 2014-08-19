class AddUsersToEvents < ActiveRecord::Migration
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
    attr_accessible :event_id, :user_id, :event_role
  end

  def up
    TempEvent.all.each do |event|
      # Create dummy user, if user doesn't exist
      unless (user = User.find_by(email: 'deleted@localhost.osem'))
        user = User.new(email: 'deleted@localhost.osem', name: 'User deleted',
                        biography: 'Data is no longer available for deleted user.',
                        password: Devise.friendly_token[0, 20])
        user.skip_confirmation!
        user.save!
      end

      event_users = TempEventUser.where(event_id: event)
      if event_users.blank?
        # Non existing users for event
        TempEventUser.create!(event_id: event.id, user_id: user.id, event_role: 'submitter')
        TempEventUser.create!(event_id: event.id, user_id: user.id, event_role: 'speaker')
      else
        # Wrong records in event_users
        event_users.each do |eu|
          unless eu.temp_user.present?
            eu.user_id = user.id
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
