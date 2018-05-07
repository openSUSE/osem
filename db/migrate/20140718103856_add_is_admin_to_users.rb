# frozen_string_literal: true

class AddIsAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_admin, :boolean, default: false
  end
end
