# frozen_string_literal: true

class AddCheckboxesForSplashComponentsToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :include_registrations_in_splash, :boolean, default: false
    add_column :conferences, :include_sponsors_in_splash, :boolean, default: false
    add_column :conferences, :include_tracks_in_splash, :boolean, default: false
    add_column :conferences, :include_tickets_in_splash, :boolean, default: false
    add_column :conferences, :include_social_media_in_splash, :boolean, default: false
    add_column :conferences, :include_program_in_splash, :boolean, default: false
  end
end
