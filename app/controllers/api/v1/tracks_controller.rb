module Api
  module V1
    class TracksController < Api::BaseController
      respond_to :json

      def index
        if params[:conference_id].blank?
          tracks = Track.all
        else
          tracks = Track.joins(:conference)
          tracks = tracks.where(conferences: { guid: params[:conference_id] })
        end
        respond_with tracks
      end
    end
  end
end
