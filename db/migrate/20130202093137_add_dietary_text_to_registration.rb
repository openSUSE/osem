# frozen_string_literal: true

class AddDietaryTextToRegistration < ActiveRecord::Migration[4.2]
  def change
    add_column :registrations, :other_dietary_choice, :text
  end
end
