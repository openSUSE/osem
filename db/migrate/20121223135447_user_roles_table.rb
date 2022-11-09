# frozen_string_literal: true

class UserRolesTable < ActiveRecord::Migration[5.0]
  def self.up
    create_table :roles_users, id: false do |t|
      t.references :role, :user
    end
  end

  def self.down
    drop_table :roles_users
  end
end
