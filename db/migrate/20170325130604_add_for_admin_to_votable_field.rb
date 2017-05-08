class AddForAdminToVotableField < ActiveRecord::Migration
  def change
    add_column :votable_fields, :for_admin, :boolean, default: false
  end
end
