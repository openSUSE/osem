class AddDescriptionAndResourceToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :description, :string
    add_reference :roles, :resource, polymorphic: true

    add_index(:roles, :name)
    add_index(:roles, [:name, :resource_type, :resource_id])
    add_index(:roles_users, [:user_id, :role_id])
  end
end
