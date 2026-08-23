class CreateEventsUsers < ActiveRecord::Migration
  def change
    create_table :events_users, id: false do |t|
      t.references :event
      t.references :user
    end
  end
end
