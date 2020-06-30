# frozen_string_literal: true

class MakeTrackStateNotNullAndAddDefaultValue < ActiveRecord::Migration[4.2]
  class TmpTrack < ActiveRecord::Base
    self.table_name = 'tracks'
  end

  def change
    TmpTrack.reset_column_information

    TmpTrack.where(state: nil).each do |track|
      track.state = 'confirmed'
      track.save!
    end

    change_column :tracks, :state, :string, null: false, default: 'new'
  end
end
