# frozen_string_literal: true

class AddHandicappedAccessToRegistrations < ActiveRecord::Migration[4.2]
  def change
    add_column :registrations, :handicapped_access_required, :boolean, default: false
  end
end
