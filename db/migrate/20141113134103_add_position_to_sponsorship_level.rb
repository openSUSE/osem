# frozen_string_literal: true

class AddPositionToSponsorshipLevel < ActiveRecord::Migration[4.2]
  def change
    add_column :sponsorship_levels, :position, :integer
  end
end
