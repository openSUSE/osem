# frozen_string_literal: true

class AddDietaryChoiceToRegistration < ActiveRecord::Migration[4.2]
  def change
    add_column :registrations, :dietary_choice_id, :integer
  end
end
