# frozen_string_literal: true

class CreateConferencesTable < ActiveRecord::Migration
  def up
    create_table :conferences do |t|
      t.string :guid, null: false
      t.string :title, null: false
      t.string :short_title, null: false
      t.string :social_tag
      t.string :contact_email, null: false
      t.string :timezone, null: false
      t.string :html_export_path
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.boolean :cfp_open, default: false
      t.boolean :registration_open, default: false
      t.references :venue

      t.timestamps
    end
  end

  def down
    drop_table :conferences
  end
end
