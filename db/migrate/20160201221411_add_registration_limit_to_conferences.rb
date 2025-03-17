# frozen_string_literal: true

class AddRegistrationLimitToConferences < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :registration_limit, :integer, default: 0
  end
end
