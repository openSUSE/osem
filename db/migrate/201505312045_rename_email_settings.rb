class RenameEmailSettings < ActiveRecord::Migration
  def up
    rename_column(:email_settings, :registration_email_template, :registration_body)
    rename_column(:email_settings, :accepted_email_template, :accepted_body)
    rename_column(:email_settings, :rejected_email_template, :rejected_body)
    rename_column(:email_settings, :confirmed_email_template, :confirmed_body)
  end

  def down
    rename_column(:email_settings, :registration_body, :registration_email_template)
    rename_column(:email_settings, :accepted_body, :accepted_email_template)
    rename_column(:email_settings, :rejected_body, :rejected_email_template)
    rename_column(:email_settings, :confirmed_body, :confirmed_email_template)
  end
end
