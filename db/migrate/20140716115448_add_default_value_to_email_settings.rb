# frozen_string_literal: true

class AddDefaultValueToEmailSettings < ActiveRecord::Migration
  def up
    change_column :email_settings, :send_on_registration, :boolean, default: false
    change_column :email_settings, :send_on_accepted, :boolean, default: false
    change_column :email_settings, :send_on_rejected, :boolean, default: false
    change_column :email_settings, :send_on_confirmed_without_registration, :boolean, default: false
    change_column :email_settings, :send_on_updated_conference_dates, :boolean, default: false
    change_column :email_settings, :send_on_updated_conference_registration_dates, :boolean, default: false
    change_column :email_settings, :send_on_venue_update, :boolean, default: false
  end

  def down
    change_column :email_settings, :send_on_registration, :boolean, default: true
    change_column :email_settings, :send_on_accepted, :boolean, default: true
    change_column :email_settings, :send_on_rejected, :boolean, default: true
    change_column :email_settings, :send_on_confirmed_without_registration, :boolean, default: true
    change_column :email_settings, :send_on_updated_conference_dates, :boolean, default: true
    change_column :email_settings, :send_on_updated_conference_registration_dates, :boolean, default: true
    change_column :email_settings, :send_on_venue_update, :boolean, default: true
  end
end
