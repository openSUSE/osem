class AddCommentCountToEvents < ActiveRecord::Migration
  def up
    add_column :events, :comments_count, :integer, default: 0

    Event.reset_column_information

    Event.find_each do |event|
      event.update_attribute :comments_count, event.comment_threads.length
    end
  end

  def down
    remove_column :events, :comments_count
  end
end
