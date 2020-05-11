# frozen_string_literal: true

class AddTrackReferenceToSchedule < ActiveRecord::Migration[4.2]
  def change
    add_reference :schedules, :track, index: true, foreign_key: true
  end
end
