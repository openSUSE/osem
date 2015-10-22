class ChangePostalcodeFormatInVenues < ActiveRecord::Migration
  def up
    change_column :venues, :postalcode, :string
  end

  def down
    raise ActiveRecord::IrreversibleMigration.new('Cannot reverse migration.')
  end
end
