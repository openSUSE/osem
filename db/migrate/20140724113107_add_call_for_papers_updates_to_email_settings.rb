# frozen_string_literal: true

class AddCallForPapersUpdatesToEmailSettings < ActiveRecord::Migration
  def change
    add_column :email_settings, :send_on_call_for_papers_dates_updates, :boolean, default: false
    add_column :email_settings, :send_on_call_for_papers_schedule_public, :boolean, default: false
    add_column :email_settings, :call_for_papers_schedule_public_subject, :string
    add_column :email_settings, :call_for_papers_dates_updates_subject, :string
    add_column :email_settings, :call_for_papers_schedule_public_template, :text
    add_column :email_settings, :call_for_papers_dates_updates_template, :text
  end
end
