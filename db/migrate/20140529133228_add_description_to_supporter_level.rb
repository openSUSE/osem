# frozen_string_literal: true

class AddDescriptionToSupporterLevel < ActiveRecord::Migration[4.2]
  def change
    add_column :supporter_levels, :description, :text
  end
end
