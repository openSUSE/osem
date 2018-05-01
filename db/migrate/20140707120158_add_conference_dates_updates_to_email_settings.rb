# frozen_string_literal: true

class AddConferenceDatesUpdatesToEmailSettings < ActiveRecord::Migration
  def change
    add_column :email_settings, :send_on_updated_conference_dates, :boolean, default: true
    add_column :email_settings, :updated_conference_dates_subject, :string
    add_column :email_settings, :updated_conference_dates_template, :text
  end
end
