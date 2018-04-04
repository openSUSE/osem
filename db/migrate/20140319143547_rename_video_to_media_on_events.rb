# frozen_string_literal: true

class RenameVideoToMediaOnEvents < ActiveRecord::Migration
  def up
    rename_column :events, :video_id, :media_id
    rename_column :events, :video_type, :media_type
  end

  def down
    rename_column :events, :media_id, :video_id
    rename_column :events, :media_type, :video_type
  end
end
