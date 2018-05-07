# frozen_string_literal: true

class CreateSponsors < ActiveRecord::Migration
  def change
    create_table :sponsors do |t|
      t.string :name
      t.text :description
      t.string :website_url
      t.string :logo_file_name
      t.string :logo_content_type
      t.integer :logo_file_size
      t.datetime :logo_updated_at
      t.belongs_to :sponsorship_level
      t.belongs_to :conference
      t.timestamps
    end
  end
end
