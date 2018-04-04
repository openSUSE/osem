# frozen_string_literal: true

class AddIndexToEventSchedule < ActiveRecord::Migration
  def change
    add_index :event_schedules, %i[event_id schedule_id], unique: true
  end
end
