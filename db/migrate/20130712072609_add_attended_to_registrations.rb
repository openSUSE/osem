# frozen_string_literal: true

class AddAttendedToRegistrations < ActiveRecord::Migration[4.2]
  def change
    add_column :registrations, :attended, :boolean, default: 0
  end
end
