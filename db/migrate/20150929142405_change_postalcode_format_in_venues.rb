# frozen_string_literal: true

class ChangePostalcodeFormatInVenues < ActiveRecord::Migration[4.2]
  def up
    change_column :venues, :postalcode, :string
  end

  def down
    raise ActiveRecord::IrreversibleMigration.new('Cannot reverse migration.')
  end
end
