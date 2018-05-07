# frozen_string_literal: true

class RenameEmailSettingsWithCfpAndProgram < ActiveRecord::Migration
  def change
    rename_column :email_settings, :send_on_call_for_papers_schedule_public, :send_on_program_schedule_public
    rename_column :email_settings, :call_for_papers_schedule_public_body, :program_schedule_public_body
    rename_column :email_settings, :call_for_papers_schedule_public_subject, :program_schedule_public_subject
    rename_column :email_settings, :send_on_call_for_papers_dates_updated, :send_on_cfp_dates_updated
    rename_column :email_settings, :call_for_papers_dates_updated_subject, :cfp_dates_updated_subject
    rename_column :email_settings, :call_for_papers_dates_updated_body, :cfp_dates_updated_body
  end
end
