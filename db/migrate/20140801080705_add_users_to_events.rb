class AddUsersToEvents < ActiveRecord::Migration
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
        # Assign sample user (created in seeds)
        user = User.find_by(email: 'deleted@localhost.osem')
        TempEventUser.create!(event_id: event.id, user_id: user.id, event_role: 'submitter')
        TempEventUser.create!(event_id: event.id, user_id: user.id, event_role: 'speaker')
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration.new('Cannot reverse migration.')
  end
end
