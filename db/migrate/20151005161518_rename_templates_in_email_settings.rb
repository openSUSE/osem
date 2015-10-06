class RenameTemplatesInEmailSettings < ActiveRecord::Migration
  def change
    rename_column :email_settings, :registration_email_template, :registration_body
    rename_column :email_settings, :accepted_email_template, :accepted_body
    rename_column :email_settings, :rejected_email_template, :rejected_body
    rename_column :email_settings, :confirmed_email_template, :confirmed_without_registration_body
    rename_column :email_settings, :updated_conference_dates_template, :updated_conference_dates_body
    rename_column :email_settings, :updated_conference_registration_dates_template, :updated_conference_registration_dates_body
    rename_column :email_settings, :venue_update_template, :venue_update_body
    rename_column :email_settings, :call_for_papers_dates_updates_template, :call_for_papers_dates_updates_body
    rename_column :email_settings, :call_for_papers_schedule_public_template, :call_for_papers_schedule_public_body
  end
end
