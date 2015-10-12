class ChangePostalcodeFormatInVenues < ActiveRecord::Migration
  def change
    change_column :venues, :postalcode, :string
  end
end
