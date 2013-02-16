class AddSpecialNeedsFieldToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :other_special_needs, :text
  end
end
