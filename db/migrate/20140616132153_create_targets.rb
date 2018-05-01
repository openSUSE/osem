# frozen_string_literal: true

class CreateTargets < ActiveRecord::Migration
  def change
    create_table :targets do |t|
      t.integer :conference_id
      t.integer :campaign_id
      t.date :due_date
      t.integer :target_count
      t.string :unit
      t.timestamps
    end
  end
end
