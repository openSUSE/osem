# frozen_string_literal: true

class AddAcceptedCodeOfConductToRegistrations < ActiveRecord::Migration[5.0]
  def change
    add_column :registrations, :accepted_code_of_conduct, :boolean
  end
end
