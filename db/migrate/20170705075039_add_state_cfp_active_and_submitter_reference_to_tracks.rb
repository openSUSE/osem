# frozen_string_literal: true

class AddStateCfpActiveAndSubmitterReferenceToTracks < ActiveRecord::Migration[4.2]
  def change
    add_column :tracks, :state, :string
    add_column :tracks, :cfp_active, :boolean
    add_column :tracks, :submitter_id, :integer
    add_index :tracks, :submitter_id
  end
end
