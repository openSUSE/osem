# frozen_string_literal: true

class AddEnabledToEventSchedules < ActiveRecord::Migration[5.0]
  def change
    add_column :event_schedules, :enabled, :boolean, default: true
  end
end
