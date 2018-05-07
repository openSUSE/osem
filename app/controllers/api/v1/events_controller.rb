# frozen_string_literal: true

module Api
  module V1
    class EventsController < Api::BaseController
      load_resource :conference, find_by: :short_title
      respond_to :json

      # Disable forgery protection for any json requests. This is required for jsonp support
      skip_before_action :verify_authenticity_token

      def index
        events = Event.includes(:track, :event_type, event_users: :user)

        if @conference
          events = events.where(program: @conference.program)
        end

        respond_with events.confirmed, callback: params[:callback]
      end
    end
  end
end
