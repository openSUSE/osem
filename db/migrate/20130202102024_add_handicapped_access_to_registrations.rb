class AddHandicappedAccessToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :handicapped_access_required, :boolean, default: false
  end
end
