class AddVideoIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :video_id, :string
    add_column :events, :video_type, :string
  end
end
