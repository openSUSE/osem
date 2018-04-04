# frozen_string_literal: true

class AddVenueCheckboxesToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :include_venue_in_splash, :boolean, default: false
    add_column :venues, :include_lodgings_in_splash, :boolean, default: false
  end
end
