# frozen_string_literal: true

class CreateRegistrationsTable < ActiveRecord::Migration
  def up
    create_table :registrations do |t|
      t.references :person
      t.references :conference

      t.boolean :attending_social_events, default: true
      t.boolean :attending_social_events_with_partner, default: false
      t.boolean :using_affiliated_lodging, default: true
      t.date :arrival
      t.date :departure

      t.timestamps
    end
  end

  def down
  end
end
