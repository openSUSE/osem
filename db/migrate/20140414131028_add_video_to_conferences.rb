# frozen_string_literal: true

class AddVideoToConferences < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :media_id, :string
    add_column :conferences, :media_type, :string
  end
end
