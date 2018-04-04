# frozen_string_literal: true

class AddDescriptionToEventType < ActiveRecord::Migration
  def change
    add_column :event_types, :description, :string
  end
end
