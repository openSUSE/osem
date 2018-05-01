# frozen_string_literal: true

class RemoveUnusedPhotoColumnsFromVenues < ActiveRecord::Migration
  def up
    remove_column :venues, :photo_updated_at
    remove_column :venues, :photo_file_size
    remove_column :venues, :photo_content_type
  end

  def down
    add_column :venues, :photo_updated_at, :datetime
    add_column :venues, :photo_file_size, :integer
    add_column :venues, :photo_content_type, :string
  end
end
