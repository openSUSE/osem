# frozen_string_literal: true

class CreateEventPeopleTable < ActiveRecord::Migration
  def self.up
    create_table :event_people do |t|
      t.references :proposal
      t.references :person
      t.references :event
      t.string :event_role, null: false, default: 'participant'
      t.string :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :event_people
  end
end
