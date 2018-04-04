# frozen_string_literal: true

class AddVenueUpdateToEmailSettings < ActiveRecord::Migration
  def change
    add_column :email_settings, :send_on_venue_update, :boolean, default: true
    add_column :email_settings, :venue_update_subject, :string
    add_column :email_settings, :venue_update_template, :text
  end
end
