module Admin
  class CommentsController < Admin::BaseController
    load_and_authorize_resource

    def index
      @comments = grouped_comments(accessible_ordered_comments)
      @unread_comments = grouped_comments(accessible_ordered_comments.find_since_last_login(current_user))
      @posted_comments = grouped_comments(accessible_ordered_comments.find_comments_by_user(current_user))
    end

    private

    def accessible_ordered_comments
      Comment.accessible_by(current_ability).joins('INNER JOIN events ON commentable_id = events.id').order('events.title', 'comments.created_at DESC')
    end

    def grouped_comments(remarks)
      remarks.group_by{ |comment| comment.commentable.conference }.map {|conference, comments| [conference, comments.group_by{|comment| comment.commentable}]}.to_h
    end
  end
end
