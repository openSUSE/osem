# frozen_string_literal: true

class CreateLodgings < ActiveRecord::Migration
  def change
    create_table :lodgings do |t|
      t.string :name
      t.text :description
      t.string :photo_file_name
      t.string :photo_content_type
      t.integer :photo_file_size
      t.datetime :photo_updated_at
      t.belongs_to :venue
      t.timestamps
    end
  end
end
