# frozen_string_literal: true

class CreateEventSchedules < ActiveRecord::Migration
  def change
    create_table :event_schedules do |t|
      t.belongs_to :event, index: true
      t.belongs_to :schedule, index: true
      t.belongs_to :room, index: true
      t.datetime :start_time
      t.timestamps null: false
    end
  end
end
