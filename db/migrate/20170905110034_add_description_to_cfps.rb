# frozen_string_literal: true

class AddDescriptionToCfps < ActiveRecord::Migration
  def change
    add_column :cfps, :description, :text
  end
end
