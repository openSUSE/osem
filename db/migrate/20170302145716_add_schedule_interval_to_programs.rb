# frozen_string_literal: true

class AddScheduleIntervalToPrograms < ActiveRecord::Migration
  def change
    add_column :programs, :schedule_interval, :integer, default: 15, null: false
  end
end
