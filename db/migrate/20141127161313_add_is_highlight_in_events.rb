class AddIsHighlightInEvents < ActiveRecord::Migration
  def change
    add_column :events, :is_highlight, :boolean, default: false
  end
end
