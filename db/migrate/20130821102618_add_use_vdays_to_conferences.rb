class AddUseVdaysToConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :use_vdays, :boolean
  end
end
