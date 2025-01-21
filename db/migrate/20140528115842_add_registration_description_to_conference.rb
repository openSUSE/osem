# frozen_string_literal: true

class AddRegistrationDescriptionToConference < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :registration_description, :text
  end
end
