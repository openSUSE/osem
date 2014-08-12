module Admin
  class TracksController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    authorize_resource through: :conference

    def index
      authorize! :index, Track.new(conference_id: @conference.id)
    end

    def show
      respond_to do |format|
        format.html { render :tracks_list }
        format.json { render json: @conference.tracks.to_json }
      end
    end

    def update
      if @conference.update_attributes(params[:conference])
        redirect_to(admin_conference_tracks_path(
                    conference_id: @conference.short_title),
                    notice: 'Tracks were successfully updated.')
      else
        redirect_to(admin_conference_tracks_path(
                    conference_id: @conference.short_title),
                    notice: 'Tracks update failed.')
      end
    end
  end
end
