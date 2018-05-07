# frozen_string_literal: true

class RemoveUnusedLogoColumnsAndUseDifficultyLevelsFromConferences < ActiveRecord::Migration
  def up
    remove_column :conferences, :logo_updated_at
    remove_column :conferences, :logo_file_size
    remove_column :conferences, :logo_content_type
    remove_column :conferences, :use_difficulty_levels
  end

  def down
    add_column :conferences, :logo_updated_at, :datetime
    add_column :conferences, :logo_file_size, :integer
    add_column :conferences, :logo_content_type, :string
    add_column :conferences, :use_difficulty_levels, :boolean, default: false
  end
end
