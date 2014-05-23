class AddRegistrationDescriptionToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :registration_description, :text
  end
end
