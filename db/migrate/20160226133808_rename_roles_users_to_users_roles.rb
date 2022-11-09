# frozen_string_literal: true

class RenameRolesUsersToUsersRoles < ActiveRecord::Migration[4.2]
  def change
    rename_table :roles_users, :users_roles
  end
end
