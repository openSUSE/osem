# frozen_string_literal: true

class CleanupVenue < ActiveRecord::Migration
  def change
    change_column :venues, :name, :string
    remove_column :venues, :offline_map_url, :string
    remove_column :venues, :offline_map_bounds, :string
  end
end
