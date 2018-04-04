# frozen_string_literal: true

class CreateEventAttachmentsTable < ActiveRecord::Migration
  def up
    create_table :event_attachments do |t|
      t.references :event
      t.string :title, null: false
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at
      t.boolean :public, default: true
      t.timestamps
    end
  end

  def down
    drop_table :event_attachments
  end
end
