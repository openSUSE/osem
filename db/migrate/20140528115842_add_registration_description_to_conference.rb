# frozen_string_literal: true

class AddRegistrationDescriptionToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :registration_description, :text
  end
end
