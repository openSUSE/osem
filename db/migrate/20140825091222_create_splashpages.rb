# frozen_string_literal: true

class CreateSplashpages < ActiveRecord::Migration
  def change
    create_table :splashpages do |t|
      t.integer :conference_id

      t.boolean :public
      t.boolean :include_tracks
      t.boolean :include_program
      t.boolean :include_social_media
      t.boolean :include_banner
      t.boolean :include_venue
      t.boolean :include_tickets
      t.text :ticket_description
      t.boolean :include_registrations
      t.text :registration_description
      t.boolean :include_sponsors
      t.text :sponsor_description
      t.boolean :include_lodgings
      t.text :lodging_description

      t.text :banner_description
      t.string :banner_photo_file_name
      t.string :banner_photo_content_type
      t.integer :banner_photo_file_size
      t.datetime :banner_photo_updated_at

      t.timestamps
    end
  end
end
