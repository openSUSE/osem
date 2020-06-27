# frozen_string_literal: true

class AddBoothLimitToConferences < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :booth_limit, :integer, default: 0
  end
end
