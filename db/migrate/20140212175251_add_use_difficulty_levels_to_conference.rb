# frozen_string_literal: true

class AddUseDifficultyLevelsToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :use_difficulty_levels, :boolean, default: false
  end
end
