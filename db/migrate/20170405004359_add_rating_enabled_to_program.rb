class AddRatingEnabledToProgram < ActiveRecord::Migration
  def change
    add_column :programs, :rating_enabled, :boolean, default: false
  end
end
