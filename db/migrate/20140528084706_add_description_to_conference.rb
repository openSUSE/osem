# frozen_string_literal: true

class AddDescriptionToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :description, :text
  end
end
