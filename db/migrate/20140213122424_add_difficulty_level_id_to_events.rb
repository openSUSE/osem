# frozen_string_literal: true

class AddDifficultyLevelIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :difficulty_level_id, :integer
  end
end
