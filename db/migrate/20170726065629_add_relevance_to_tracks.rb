# frozen_string_literal: true

class AddRelevanceToTracks < ActiveRecord::Migration[4.2]
  def change
    add_column :tracks, :relevance, :text
  end
end
