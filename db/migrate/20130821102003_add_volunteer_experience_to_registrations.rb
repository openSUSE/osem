# frozen_string_literal: true

class AddVolunteerExperienceToRegistrations < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :volunteer_experience, :text
  end
end
