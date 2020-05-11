# frozen_string_literal: true

class AddRoomAndDatesToTracks < ActiveRecord::Migration[4.2]
  def change
    add_reference :tracks, :room, index: true, foreign_key: true
    add_column :tracks, :start_date, :date
    add_column :tracks, :end_date, :date
  end
end
