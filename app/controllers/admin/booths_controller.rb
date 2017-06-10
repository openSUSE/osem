module Admin
  class Admin::BoothsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :booth, through: :conference

    def index
      @booths = @conference.booths
    end

    def show; end

    def new; end

    def create; end

    def update; end

    def destroy; end

  end
end
