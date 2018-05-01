# frozen_string_literal: true

class MakeTrackCfpActiveNotNull < ActiveRecord::Migration
  class TmpTrack < ApplicationRecord
    self.table_name = 'tracks'
  end

  def change
    TmpTrack.where(cfp_active: nil).each do |track|
      track.cfp_active = true
      track.save!
    end

    change_column_null :tracks, :cfp_active, false
  end
end
