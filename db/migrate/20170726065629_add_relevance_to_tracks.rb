class AddRelevanceToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :relevance, :text
  end
end
