# frozen_string_literal: true

class AddRegistrationLimitToConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :registration_limit, :integer, default: 0
  end
end
