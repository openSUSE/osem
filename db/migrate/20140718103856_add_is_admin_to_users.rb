# frozen_string_literal: true

class AddIsAdminToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :is_admin, :boolean, default: false
  end
end
