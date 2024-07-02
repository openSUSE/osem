# frozen_string_literal: true

class SetRegistrationDefaultsToFalse < ActiveRecord::Migration[4.2]
  def up
    change_column :registrations, :using_affiliated_lodging, :boolean, default: false
  end

  def down
  end
end
