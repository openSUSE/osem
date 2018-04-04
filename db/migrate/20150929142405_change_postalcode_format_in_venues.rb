# frozen_string_literal: true

class ChangePostalcodeFormatInVenues < ActiveRecord::Migration
  def up
    change_column :venues, :postalcode, :string
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Cannot reverse migration.'
  end
end
