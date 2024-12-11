# frozen_string_literal: true

class AddVolunteerToRegistrations < ActiveRecord::Migration[4.2]
  def change
    add_column :registrations, :volunteer, :boolean
  end
end
