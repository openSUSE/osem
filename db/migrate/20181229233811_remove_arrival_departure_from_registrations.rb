class RemoveArrivalDepartureFromRegistrations < ActiveRecord::Migration[5.0]
  def change
    remove_column :registrations, :arrival, :datetime
    remove_column :registrations, :departure, :datetime
  end
end
