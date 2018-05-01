# frozen_string_literal: true

class AddSubjectsToEmailSettings < ActiveRecord::Migration
  def change
    add_column :email_settings, :registration_subject, :string
    add_column :email_settings, :accepted_subject, :string
    add_column :email_settings, :rejected_subject, :string
    add_column :email_settings, :confirmed_without_registration_subject, :string
  end
end
