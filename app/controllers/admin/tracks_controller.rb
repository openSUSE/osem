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
        redirect_to(admin_conference_tracks_path(conference_id: @conference.short_title),
                    notice: 'Track successfully created.')
      else
        flash[:error] = "Creating Track failed: #{@track.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def edit; end

    def update
      if @track.update_attributes(track_params)
        redirect_to(admin_conference_tracks_path(conference_id: @conference.short_title),
                    notice: 'Track successfully updated.')
      else
        flash[:error] = "Track update failed: #{@track.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @track.destroy
        redirect_to(admin_conference_tracks_path(conference_id: @conference.short_title),
                    notice: 'Track successfully deleted.')
      else
        redirect_to(admin_conference_tracks_path(conference_id: @conference.short_title),
                    error: 'Track couldn\'t be deleted.' \
                    "#{@track.errors.full_messages.join('. ')}.")
      end
    end

    private

    def track_params
      params[:track]
    end
  end
end
