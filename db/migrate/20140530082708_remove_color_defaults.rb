# frozen_string_literal: true

class RemoveColorDefaults < ActiveRecord::Migration[4.2]
  def change
    change_column_default(:tracks, :color, nil)
    change_column_default(:conferences, :color, nil)
    change_column_default(:difficulty_levels, :color, nil)
  end
end
