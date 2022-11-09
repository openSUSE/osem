# frozen_string_literal: true

class AddLodgingDescriptionToConference < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :lodging_description, :text
  end
end
