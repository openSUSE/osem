class TracksController < ApplicationController
  load_resource :conference, find_by: :short_title
  load_resource :program, through: :conference, singleton: true
  load_and_authorize_resource through: :program, find_by: :short_name

  def index
    @tracks = current_user.tracks.where(program: @program)
  end

  def show; end

  def new
    @track = @program.tracks.new(color: @conference.next_color_for_collection(:tracks))
  end

  def edit; end

  def create
    @track = @program.tracks.new(track_params)
    @track.submitter = current_user
    @track.cfp_active = false
    if @track.save
      redirect_to conference_program_tracks_path(conference_id: @conference.short_title),
                  notice: 'Track request successfully created.'
    else
      flash.now[:error] = "Creating Track request failed: #{@track.errors.full_messages.join('. ')}."
      render :new
    end
  end

  def update
    if @track.update_attributes(track_params)
      redirect_to conference_program_tracks_path(conference_id: @conference.short_title),
                  notice: 'Track request successfully updated.'
    else
      flash.now[:error] = "Track request update failed: #{@track.errors.full_messages.join('. ')}."
      render :edit
    end
  end

  private

  def track_params
    params.require(:track).permit(:name, :description, :color, :short_name)
  end
end
