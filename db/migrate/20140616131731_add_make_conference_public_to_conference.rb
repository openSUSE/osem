# frozen_string_literal: true

class AddMakeConferencePublicToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :make_conference_public, :boolean, default: false
  end
end
