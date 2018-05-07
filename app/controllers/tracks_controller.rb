# frozen_string_literal: true

class TracksController < ApplicationController
  load_resource :conference, find_by: :short_title
  load_resource :program, through: :conference, singleton: true
  load_and_authorize_resource through: :program, find_by: :short_name

  def index
    @tracks = @tracks.where(submitter: current_user)
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

  def restart
    update_state(:restart, "Track #{@track.name} re-submitted.")
  end

  def confirm
    update_state(:confirm, "Track #{@track.name} confirmed.")
  end

  def withdraw
    update_state(:withdraw, "Track #{@track.name} withdrawn.")
  end

  private

  def track_params
    params.require(:track).permit(:name, :description, :color, :short_name, :start_date, :end_date, :relevance)
  end

  def update_state(transition, notice)
    errors = @track.update_state(transition)

    if errors.blank?
      flash[:notice] = notice
    else
      flash[:error] = errors
    end

    redirect_back_or_to(conference_program_tracks_path(conference_id: @conference.short_title))
  end
end
