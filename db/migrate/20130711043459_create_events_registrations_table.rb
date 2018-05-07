# frozen_string_literal: true

class CreateEventsRegistrationsTable < ActiveRecord::Migration
  def up
    create_table :events_registrations, id: false do |t|
      t.references :registration, :event
    end
  end

  def down
    drop_table :events_registrations
  end
end
