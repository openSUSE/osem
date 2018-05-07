# frozen_string_literal: true

class AddLodgingDescriptionToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :lodging_description, :text
  end
end
