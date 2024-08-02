# frozen_string_literal: true

class AddUseDifficultyLevelsToConference < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :use_difficulty_levels, :boolean, default: false
  end
end
