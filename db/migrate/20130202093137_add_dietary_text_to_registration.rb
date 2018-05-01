# frozen_string_literal: true

class AddDietaryTextToRegistration < ActiveRecord::Migration
  def change
    add_column :registrations, :other_dietary_choice, :text
  end
end
