# frozen_string_literal: true

class AddSponsorDescriptionToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :sponsor_description, :text
  end
end
