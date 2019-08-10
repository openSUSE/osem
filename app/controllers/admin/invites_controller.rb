module Admin
  class InvitesController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title

    def new
      @invite = @conference.invites.new
    end

    def create; end
  end
end
