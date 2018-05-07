# frozen_string_literal: true

module Admin
  class CommentsController < Admin::BaseController
    load_and_authorize_resource

    def index
      # All available comments, grouped and sorted
      @comments = grouped_comments(accessible_ordered_comments)

      # Grouped, sorted, available comments, posted since current_user last login
      @unread_comments = grouped_comments(accessible_ordered_comments.find_since_last_login(current_user))

      # Grouped, sorted, available comments, posted by current_user
      @posted_comments = grouped_comments(accessible_ordered_comments.find_comments_by_user(current_user))
    end

    private

    # Returning all available comments, ordered by created_at: :desc and by event.title
    def accessible_ordered_comments
      Comment.accessible_by(current_ability).joins('INNER JOIN events ON commentable_id = events.id').order('events.title', 'comments.created_at DESC')
    end

# Grouping all comments by conference, and by event. It returns {:conference => {:event => [{comment_2}, {comment_1 }]}}
    def grouped_comments(remarks)
      remarks.group_by{ |comment| comment.commentable.program.conference }.map {|conference, comments| [conference, comments.group_by{|comment| comment.commentable}]}.to_h
    end
  end
end
