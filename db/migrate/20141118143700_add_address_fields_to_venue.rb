# frozen_string_literal: true

class AddAddressFieldsToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :street, :string
    add_column :venues, :postalcode, :integer
    add_column :venues, :city, :string
    add_column :venues, :country, :string
    add_column :venues, :latitude, :string
    add_column :venues, :longitude, :string

    remove_column :venues, :address, :text
  end
end
