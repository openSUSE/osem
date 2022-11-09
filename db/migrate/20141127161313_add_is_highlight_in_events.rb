# frozen_string_literal: true

class AddIsHighlightInEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :is_highlight, :boolean, default: false
  end
end
