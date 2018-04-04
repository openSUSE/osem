# frozen_string_literal: true

class MakeTrackStateNotNullAndAddDefaultValue < ActiveRecord::Migration
  class TmpTrack < ApplicationRecord
    self.table_name = 'tracks'
  end

  def change
    TmpTrack.where(state: nil).each do |track|
      track.state = 'confirmed'
      track.save!
    end

    change_column :tracks, :state, :string, null: false, default: 'new'
  end
end
