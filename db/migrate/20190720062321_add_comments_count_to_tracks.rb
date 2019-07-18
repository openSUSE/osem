class AddCommentsCountToTracks < ActiveRecord::Migration[5.1]
  def change
    add_column :tracks, :comments_count, :integer, default: 0, null: false

    Track.find_each do |track|
      comments_count = track.comment_threads.count
      track.update_attributes(:comments_count, comments_count) unless comments_count.zero?
    end
  end
end
