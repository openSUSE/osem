# frozen_string_literal: true

class RemovePhotos < ActiveRecord::Migration
  def change
    drop_table :photos do |t|
      t.text :description
      t.string :picture_file_name
      t.string :picture_content_type
      t.integer :picture_file_size
      t.datetime :picture_updated_at
      t.belongs_to :conference
      t.timestamps
    end
  end
end
