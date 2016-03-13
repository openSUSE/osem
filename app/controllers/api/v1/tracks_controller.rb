module Api
  module V1
    class TracksController < Api::BaseController
      load_resource :conference, find_by: :short_title
      respond_to :json

      def index
        @conference ? (tracks = @conference.program.tracks) : (tracks = Track.all)

        respond_with tracks
      end
    end
  end
end
