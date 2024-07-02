# frozen_string_literal: true

class AddSponsorDescriptionToConference < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :sponsor_description, :text
  end
end
