module Admin
  class CommentsController < Admin::BaseController
    load_and_authorize_resource

    def index
      @comments = Comment.accessible_by(current_ability).order(created_at: :desc).group_by { |comment| comment.commentable.conference }
      @another_comments = Hash[@comments.map{|conference, comments| [conference, comments.group_by {|comment| comment.commentable}]}]
    end
  end
end
