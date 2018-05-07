# frozen_string_literal: true

class AddMaxAttendeesToEvents < ActiveRecord::Migration
  def change
    add_column :events, :max_attendees, :integer
  end
end
