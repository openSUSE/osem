class DeleteEventsWithoutUser < ActiveRecord::Migration

  def up
    # User deletion without all the proper dependent: :destroy options might have left
    # Events without a submitter (event_user association is deleted, but Event itslef is not)
    Event.all.each do |event|
      if event.users.blank?
        event.destroy
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Cannot reverse migration. Events deleted cannot be re-created'
  end
end
