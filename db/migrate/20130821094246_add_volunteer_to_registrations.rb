# frozen_string_literal: true

class AddVolunteerToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :volunteer, :boolean
  end
end
