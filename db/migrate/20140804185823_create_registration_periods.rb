# frozen_string_literal: true

class CreateRegistrationPeriods < ActiveRecord::Migration
  def up
    create_table :registration_periods do |t|
      t.integer :conference_id
      t.date :start_date
      t.date :end_date
      t.text :description

      t.timestamps
    end
  end

  def down
    drop_table :registration_periods
  end
end
