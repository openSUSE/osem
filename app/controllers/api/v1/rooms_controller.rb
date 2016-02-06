module Api
  module V1
    class RoomsController < Api::BaseController
      load_resource :conference, find_by: :short_title
      respond_to :json

      def index
        @conference ? (rooms = @conference.rooms) : (rooms = Room.all)

        respond_with rooms
      end
    end
  end
end
