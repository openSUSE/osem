class AddOrganizatonIdToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :organization_id, :integer
  end
end
