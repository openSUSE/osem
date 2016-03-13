module Api
  module V1
    class RoomsController < Api::BaseController
      load_resource :conference, find_by: :short_title
      respond_to :json

      def index
        if params[:conference_id].blank?
          rooms = Room.all
        else
          @conference.venue ? (rooms = @conference.venue.rooms) : (rooms = [])
        end
        respond_with rooms
      end
    end
  end
end
