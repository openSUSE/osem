# frozen_string_literal: true

class AddAttendedToEventsRegistrations < ActiveRecord::Migration
  def change
    add_column :events_registrations, :attended, :boolean, default: false, null: false
  end
end
