# frozen_string_literal: true

class AddMaxAttendeesToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :max_attendees, :integer
  end
end
