class ChangePostalcodeFormatInVenues < ActiveRecord::Migration
  def up
    change_column :venues, :postalcode, :string
  end

  def down
    change_column :venues, :postalcode, :integer
  end
end
