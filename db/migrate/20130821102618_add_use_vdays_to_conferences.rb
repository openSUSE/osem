# frozen_string_literal: true

class AddUseVdaysToConferences < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :use_vdays, :boolean
  end
end
