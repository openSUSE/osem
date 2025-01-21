# frozen_string_literal: true

class AddWebsiteLinkToLodging < ActiveRecord::Migration[4.2]
  def change
    add_column :lodgings, :website_link, :string
  end
end
