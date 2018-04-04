# frozen_string_literal: true

class AddCreatedAtAndUpdatedAtToEventTypes < ActiveRecord::Migration[5.0]
  def up
    add_column :event_types, :created_at, :datetime
    add_column :event_types, :updated_at, :datetime
    EventType.update_all(created_at: Time.now, updated_at: Time.now)
  end

  def down
    remove_column :event_types, :created_at
    remove_column :event_types, :updated_at
  end
end
