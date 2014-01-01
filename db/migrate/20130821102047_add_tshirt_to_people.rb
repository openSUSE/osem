class AddTshirtToPeople < ActiveRecord::Migration
  def change
    add_column :people, :tshirt, :string
  end
end
