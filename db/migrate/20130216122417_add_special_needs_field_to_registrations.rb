# frozen_string_literal: true

class AddSpecialNeedsFieldToRegistrations < ActiveRecord::Migration[4.2]
  def change
    add_column :registrations, :other_special_needs, :text
  end
end
