class AddCommentsCountToEvents < ActiveRecord::Migration
  def change
    add_column :events, :comments_count, :integer, default: 0, null: false

    Event.find_each do |event|
      comments_count = event.comment_threads.count
      event.update_attribute(:comments_count, comments_count) unless comments_count.zero?
    end
  end
end
