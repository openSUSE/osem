# frozen_string_literal: true

class CreateRegistrationsSocialEventsTable < ActiveRecord::Migration
  def up
    create_table :registrations_social_events, id: false do |t|
      t.references :registration, :social_event
    end
  end

  def down
    drop_table :registrations_social_events
  end
end
