# frozen_string_literal: true

class AddVideoIdToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :video_id, :string
    add_column :events, :video_type, :string
  end
end
