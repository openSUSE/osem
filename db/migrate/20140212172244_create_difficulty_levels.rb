# frozen_string_literal: true

class CreateDifficultyLevels < ActiveRecord::Migration
  def change
    create_table :difficulty_levels do |t|
      t.references :conference
      t.string :title
      t.text :description
      t.string :color, default: '#ffffff'

      t.timestamps
    end
  end
end
