# frozen_string_literal: true

module Api
  module V1
    class TracksController < Api::BaseController
      load_resource :conference, find_by: :short_title
      respond_to :json

      # Disable forgery protection for any json requests. This is required for jsonp support
      skip_before_action :verify_authenticity_token

      def index
        tracks = @conference ? @conference.program.tracks : Track.all

        respond_with tracks, callback: params[:callback]
      end
    end
  end
end
