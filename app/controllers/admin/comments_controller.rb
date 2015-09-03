module Admin
  class CommentsController < Admin::BaseController
    load_and_authorize_resource

    def index
      @conferences_available = Conference.with_roles([:admin, :organizer, :cfp], current_user)
    end
  end
end
