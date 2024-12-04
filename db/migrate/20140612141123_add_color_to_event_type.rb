# frozen_string_literal: true

class AddColorToEventType < ActiveRecord::Migration[4.2]
  def change
    add_column :event_types, :color, :string
  end
end
