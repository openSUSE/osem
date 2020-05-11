# frozen_string_literal: true

class AddDescriptionToCfps < ActiveRecord::Migration[4.2]
  def change
    add_column :cfps, :description, :text
  end
end
