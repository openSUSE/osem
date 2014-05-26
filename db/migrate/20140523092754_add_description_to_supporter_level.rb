class AddDescriptionToSupporterLevel < ActiveRecord::Migration
  def change
    add_column :supporter_levels, :description, :text
  end
end
