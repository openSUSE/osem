# frozen_string_literal: true

class RemoveLogoAndProgressAndTimeSlotsFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :logo_file_name
    remove_column :events, :logo_updated_at
    remove_column :events, :logo_file_size
    remove_column :events, :logo_content_type
    remove_column :events, :time_slots
  end

  def down
    add_column :events, :logo_file_name, :string
    add_column :events, :logo_updated_at, :datetime
    add_column :events, :logo_file_size, :integer
    add_column :events, :logo_content_type, :string
    add_column :events, :time_slots, :integer
    add_column :events, :progress, :string, default: 'new', null: false
  end
end
