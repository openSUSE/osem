# frozen_string_literal: true

class MakeTrackCfpActiveNotNull < ActiveRecord::Migration[4.2]
  class TmpTrack < ActiveRecord::Base
    self.table_name = 'tracks'
  end

  def change
    TmpTrack.reset_column_information

    TmpTrack.where(cfp_active: nil).each do |track|
      track.cfp_active = true
      track.save!
    end

    change_column :tracks, :cfp_active, :boolean, null: false, default: false
  end
end
