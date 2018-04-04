# frozen_string_literal: true

class AddIdToUsersRoles < ActiveRecord::Migration
  def change
    add_column :users_roles, :id, :primary_key
  end
end
