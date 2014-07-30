class DeleteEventsWithoutUser < ActiveRecord::Migration

  class TempEvent < ActiveRecord::Base
    self.table_name = 'events'
  end

  class TempUser < ActiveRecord::Base
    self.table_name = 'users'
  end

  class TempEventUser < ActiveRecord::Base
    self.table_name = 'event_users'
    attr_accessible :event_id, :user_id, :event_role
  end

  def up
    TempEvent.all.each do |event|
      if TempEventUser.where(event_id: event).blank?
        # Create dummy user
        unless (user = User.find_by(email: 'deleted@localhost.osem'))
          user = User.new(email: 'deleted@localhost.osem', name: 'User deleted',
                              biography: 'Data is no longer available for deleted user.',
                              password: Devise.friendly_token[0, 20])
          user.skip_confirmation!
          user.save!
        end

        TempEventUser.create!(event_id: event.id, user_id: user.id, event_role: 'submitter')
        TempEventUser.create!(event_id: event.id, user_id: user.id, event_role: 'speaker')
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Cannot reverse migration. Events deleted cannot be re-created'
  end
end
