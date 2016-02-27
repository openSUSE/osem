module Api
  module V1
    class EventsController < Api::BaseController
      load_resource :conference, find_by: :short_title
      respond_to :json

      def index
        events = Event.includes(:conference, :track, :room, :event_type, event_users: :user)

        if @conference
          events = events.where(conference: @conference)
        end

        respond_with events.confirmed
      end
    end
  end
end
