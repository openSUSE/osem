class AddVolunteerExperienceToRegistrations < ActiveRecord::Migration
  def change
    add_column :people, :volunteer_experience, :text
  end
end
