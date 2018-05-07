# frozen_string_literal: true

class UndoWrongMigration20140801080705AddUsersToEvents < ActiveRecord::Migration
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

  class Version < ActiveRecord::Base
    self.table_name = 'versions'
  end

  def up
    if ActiveRecord::Migrator.get_all_versions.include? 20140801080705
      user_deleted = TempUser.find_by(email: 'deleted@localhost.osem')

      TempEvent.all.each do |event|
        whodunnit = Version.find_by(item_type: 'Event', item_id: event.id, event: 'create').whodunnit
        original_user = TempUser.find_by(id: whodunnit)

        if original_user.blank?
          original_submitter = user_deleted
        else
          original_submitter = original_user
        end

        # Substitute submitter record
        submitter = TempEventUser.find_by(event_id: event.id, event_role: 'submitter')
        submitter.user_id = original_submitter.id
        submitter.save!

        # Substitute speaker record
        speaker = TempEventUser.find_by(event_id: event.id, event_role: 'speaker')
        speaker.user_id = original_submitter.id
        speaker.save!
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration.new('Cannot reverse migration.')
  end
end
