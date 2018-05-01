# frozen_string_literal: true

class CreateCfpTable < ActiveRecord::Migration
  def up
    create_table :call_for_papers do |t|
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.date :hard_deadline, null: false
      t.text :description, null: false
      t.references :conference

      t.timestamps
    end
  end

  def down
    drop_table :call_for_papers
  end
end
