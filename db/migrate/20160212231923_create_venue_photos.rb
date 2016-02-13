class CreateVenuePhotos < ActiveRecord::Migration
  def change
    create_table :venue_photos do |t|
      t.integer :venue_id
      t.string :photo_file_name
      t.string :photo_content_type
      t.integer :photo_file_size
      t.datetime :photo_updated_at

      t.timestamps null: false
    end
  end
end
