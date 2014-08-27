module Api
  module V1
    class SpeakersController < Api::BaseController
      respond_to :json

      def index
        if params[:conference_id].blank?
          users = User.joins(:event_users)
        else
          users = User.joins(event_users: { event: :conference })
          users = users.where(conferences: { guid: params[:conference_id] })
        end
        users = users.where(event_users: {event_role: :speaker})
        render json: users, each_serializer: SpeakerSerializer
      end
    end
  end
end
