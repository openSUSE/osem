# frozen_string_literal: true

class RenameRolesUsersToUsersRoles < ActiveRecord::Migration
  def change
    rename_table :roles_users, :users_roles
  end
end
