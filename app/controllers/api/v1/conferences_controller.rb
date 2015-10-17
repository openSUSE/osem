module Api
  module V1
    class ConferencesController < Api::BaseController
      respond_to :json

      def index
        if params[:conference_id].blank?
          conferences = Conference.all
        else
          conferences = Conference.find_by(short_title: params[:conference_id])
        end
        render json: conferences, serializer: ConferencesArraySerializer
      end
    end
  end
end
