# frozen_string_literal: true

class AddVideoToConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :media_id, :string
    add_column :conferences, :media_type, :string
  end
end
