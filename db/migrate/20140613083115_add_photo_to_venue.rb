# frozen_string_literal: true

class AddPhotoToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :photo_file_name, :string
    add_column :venues, :photo_content_type, :string
    add_column :venues, :photo_file_size, :integer
    add_column :venues, :photo_updated_at, :datetime
  end
end
