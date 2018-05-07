# frozen_string_literal: true

class CreateEventsTable < ActiveRecord::Migration
  def up
    create_table :events do |t|
      t.string :guid, null: false
      t.references :conference
      t.references :event_type
      t.string :title, null: false
      t.string :subtitle
      t.integer :time_slots
      t.string :state, null: false, default: 'new'
      t.string :progress, null: false, default: 'new'
      t.string :language
      t.datetime :start_time
      t.text :abstract
      t.text :description
      t.boolean :public, default: true
      t.string :logo_file_name
      t.string :logo_content_type
      t.integer :logo_file_size
      t.datetime :logo_updated_at
      t.text :proposal_additional_speakers
      t.references :track
      t.references :room

      t.timestamps
    end
  end

  def down
  end
end
