# frozen_string_literal: true

class AddCreatedAtToSupporterRegistrations < ActiveRecord::Migration
  def change
    add_column :supporter_registrations, :created_at, :datetime
  end
end
