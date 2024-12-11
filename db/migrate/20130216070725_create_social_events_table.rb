# frozen_string_literal: true

class CreateSocialEventsTable < ActiveRecord::Migration[4.2]
  def up
    create_table :social_events do |t|
      t.references :conference
      t.string :title
      t.text :description
      t.date :date
    end
  end

  def down
    drop_table :social_events
  end
end
