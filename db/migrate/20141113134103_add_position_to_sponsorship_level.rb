class AddPositionToSponsorshipLevel < ActiveRecord::Migration
  def change
    add_column :sponsorship_levels, :position, :integer
  end
end
