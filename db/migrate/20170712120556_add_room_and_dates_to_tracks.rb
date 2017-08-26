class AddRoomAndDatesToTracks < ActiveRecord::Migration
  def change
    add_reference :tracks, :room, index: true, foreign_key: true
    add_column :tracks, :start_date, :date
    add_column :tracks, :end_date, :date
  end
end
