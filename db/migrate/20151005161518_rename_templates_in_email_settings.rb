# frozen_string_literal: true

class RenameTemplatesInEmailSettings < ActiveRecord::Migration
  def change
    rename_column :email_settings, :registration_email_template, :registration_body
    rename_column :email_settings, :accepted_email_template, :accepted_body
    rename_column :email_settings, :rejected_email_template, :rejected_body
    rename_column :email_settings, :confirmed_email_template, :confirmed_without_registration_body
    rename_column :email_settings, :send_on_updated_conference_dates, :send_on_conference_dates_updated
    rename_column :email_settings, :updated_conference_dates_subject, :conference_dates_updated_subject
    rename_column :email_settings, :updated_conference_dates_template, :conference_dates_updated_body
    rename_column :email_settings, :send_on_updated_conference_registration_dates, :send_on_conference_registration_dates_updated
    rename_column :email_settings, :updated_conference_registration_dates_subject, :conference_registration_dates_updated_subject
    rename_column :email_settings, :updated_conference_registration_dates_template, :conference_registration_dates_updated_body
    rename_column :email_settings, :send_on_venue_update, :send_on_venue_updated
    rename_column :email_settings, :venue_update_subject, :venue_updated_subject
    rename_column :email_settings, :venue_update_template, :venue_updated_body
    rename_column :email_settings, :send_on_call_for_papers_dates_updates, :send_on_call_for_papers_dates_updated
    rename_column :email_settings, :call_for_papers_dates_updates_subject, :call_for_papers_dates_updated_subject
    rename_column :email_settings, :call_for_papers_dates_updates_template, :call_for_papers_dates_updated_body
    rename_column :email_settings, :call_for_papers_schedule_public_template, :call_for_papers_schedule_public_body
  end
end
