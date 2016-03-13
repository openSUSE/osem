module Api
  module V1
    class RoomsController < Api::BaseController
      load_resource :conference, find_by: :short_title
      respond_to :json

      def index
        if @conference
          respond_with @conference.venue ? @conference.venue.rooms : Room.none
        else
          respond_with Room.all
        end
      end
    end
  end
end
