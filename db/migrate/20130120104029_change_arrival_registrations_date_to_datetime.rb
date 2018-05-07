# frozen_string_literal: true

class ChangeArrivalRegistrationsDateToDatetime < ActiveRecord::Migration
  def up
    change_column :registrations, :arrival, :datetime
    change_column :registrations, :departure, :datetime
  end

  def down
    change_column :registrations, :arrival, :date
    change_column :registrations, :departure, :date
  end
end
