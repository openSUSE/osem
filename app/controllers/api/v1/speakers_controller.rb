# frozen_string_literal: true

module Api
  module V1
    class SpeakersController < Api::BaseController
      load_resource :conference, find_by: :short_title
      respond_to :json

      # Disable forgery protection for any json requests. This is required for jsonp support
      skip_before_action :verify_authenticity_token

      def index
        if @conference
          users = User.joins(event_users: { event: { program: :conference} })
          users = users.where(conferences: { short_title: @conference.short_title })
        else
          users = User.joins(:event_users)
        end

        users = users.where(event_users: {event_role: :speaker}).uniq
        render json:            users,
               each_serializer: SpeakerSerializer,
               callback:        params['callback'],
               root:            'speakers'
      end
    end
  end
end
