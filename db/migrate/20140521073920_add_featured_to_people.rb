class AddFeaturedToPeople < ActiveRecord::Migration
  def change
    add_column :people, :featured, :boolean, default: false
  end
end
