# frozen_string_literal: true

class AddWeekToEvent < ActiveRecord::Migration
  class Event < ActiveRecord::Base
  end

  def up
    add_column :events, :week, :integer
    Event.reset_column_information
    Event.find_each do |event|
      event.week = event.created_at.strftime('%W')
      event.save!
    end
  end

  def down
    remove_column :events, :week
  end
end
