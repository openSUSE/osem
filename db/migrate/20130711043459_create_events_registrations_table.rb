# frozen_string_literal: true

class CreateEventsRegistrationsTable < ActiveRecord::Migration[4.2]
  def up
    create_table :events_registrations, id: false do |t|
      t.references :registration, :event
    end
  end

  def down
    drop_table :events_registrations
  end
end
