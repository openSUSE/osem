module Admin
  class TracksController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :track, through: :conference

    def index; end

    def show
      respond_to do |format|
        format.html { render }
        format.json { render json: @conference.tracks.to_json }
      end
    end

    def new
      @track = @conference.tracks.new
    end

    def create
      @track = @conference.tracks.new(track_params)
      if @track.save
        flash[:notice] = 'Track successfully created.'
        redirect_to(admin_conference_tracks_path(conference_id: @conference.short_title))
      else
        flash[:error] = "Creating Track failed: #{@track.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def edit; end

    def update
      if @track.update_attributes(track_params)
        flash[:notice] = 'Track successfully updated.'
        redirect_to(admin_conference_tracks_path(conference_id: @conference.short_title))
      else
        flash[:error] = "Track update failed: #{@track.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @track.destroy
        flash[:notice] = 'Track successfully deleted.'
        redirect_to(admin_conference_tracks_path(conference_id: @conference.short_title))
      else
        flash[:error] = "Track couldn't be deleted. #{@track.errors.full_messages.join('. ')}."
        redirect_to(admin_conference_tracks_path(conference_id: @conference.short_title))
      end
    end

    private

    def track_params
      params[:track]
    end
  end
end
