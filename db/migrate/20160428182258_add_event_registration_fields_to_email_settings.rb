class AddEventRegistrationFieldsToEmailSettings < ActiveRecord::Migration
  def change
    add_column :email_settings, :send_on_updated_max_attendees_automatically, :boolean
    add_column :email_settings, :updated_max_attendees_automatically_subject, :string
    add_column :email_settings, :updated_max_attendees_automatically_body, :text

    add_column :email_settings, :send_on_deleted_event_registration_automatically, :boolean
    add_column :email_settings, :deleted_event_registration_automatically_subject, :string
    add_column :email_settings, :deleted_event_registration_automatically_body, :text

    add_column :email_settings, :send_on_new_event_registration, :boolean
    add_column :email_settings, :new_event_registration_subject, :string
    add_column :email_settings, :new_event_registration_body, :text
  end
end
