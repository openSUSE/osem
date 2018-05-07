# frozen_string_literal: true

class AddDietaryChoiceToRegistration < ActiveRecord::Migration
  def change
    add_column :registrations, :dietary_choice_id, :integer
  end
end
