# frozen_string_literal: true

class AddWeekToRegistration < ActiveRecord::Migration
  class Registration < ActiveRecord::Base
  end

  def up
    add_column :registrations, :week, :integer
    Registration.reset_column_information
    Registration.find_each do |registration|
      registration.week = registration.created_at.strftime('%W')
      registration.save!
    end
  end

  def down
    remove_column :registrations, :week
  end
end
