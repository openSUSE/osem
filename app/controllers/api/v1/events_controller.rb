module Api
  module V1
    class EventsController < Api::BaseController
      respond_to :json

      def index
        events = Event.includes(:conference, :track, :room, :event_type, event_users: :user)
        unless params[:conference_id].blank?
          events = events.where(conferences: { guid: params[:conference_id] })
        end
        respond_with events.confirmed
      end
    end
  end
end
