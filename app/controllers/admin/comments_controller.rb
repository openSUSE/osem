module Admin
  class CommentsController < Admin::BaseController
    load_and_authorize_resource

    def index
      @comments = Comment.accessible_by(current_ability).joins('INNER JOIN events ON commentable_id = events.id').order('events.title', 'comments.created_at DESC').group_by{ |comment| comment.commentable.conference }.map {|conference, comments| [conference, comments.group_by{|comment| comment.commentable}]}.to_h
    end
  end
end
