# frozen_string_literal: true

class CreateSupporterLevelTable < ActiveRecord::Migration[4.2]
  def up
    create_table :supporter_levels do |t|
      t.references :conference
      t.string :title, null: false
      t.string :url
    end
  end

  def down
    drop_table :supporter_levels
  end
end
