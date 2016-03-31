module Api
  module V1
    class SpeakersController < Api::BaseController
      load_resource :conference, find_by: :short_title
      respond_to :json

      def index
        if @conference
          users = User.joins(event_users: { event: { program: :conference} })
          users = users.where(conferences: { short_title: @conference.short_title })
        else
          users = User.joins(:event_users)
        end

        users = users.where(event_users: {event_role: :speaker}).uniq
        render json: users, each_serializer: SpeakerSerializer
      end
    end
  end
end
