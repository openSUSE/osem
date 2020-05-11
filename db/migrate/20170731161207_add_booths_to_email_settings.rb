# frozen_string_literal: true

class AddBoothsToEmailSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :email_settings, :send_on_booths_acceptance, :boolean, default: false
    add_column :email_settings, :booths_acceptance_subject, :string
    add_column :email_settings, :booths_acceptance_body, :text
    add_column :email_settings, :send_on_booths_rejection, :boolean, default: false
    add_column :email_settings, :booths_rejection_subject, :string
    add_column :email_settings, :booths_rejection_body, :text
  end
end
