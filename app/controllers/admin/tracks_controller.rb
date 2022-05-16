# frozen_string_literal: true

module Admin
  class TracksController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :program, through: :conference, singleton: true
    load_and_authorize_resource through: :program, find_by: :short_name

    # Show flash message with ajax calls
    after_action :prepare_unobtrusive_flash, only: :toggle_cfp_inclusion

    def index
      @file_name = "tracks_for_#{@conference.short_title}"
      @track_export_option = params[:track_export_option]

      respond_to do |format|
        format.html
        # Explicitly call #to_json to avoid the use of EventSerializer
        format.json { render json: Track.where(state: :confirmed, program: @program).to_json }
        format.xlsx do
          response.headers['Content-Disposition'] = "attachment; filename=\"#{@file_name}.xlsx\""
          render 'tracks', layout: false
        end
        format.pdf { render 'tracks', layout: false }
        format.csv do
          response.headers['Content-Disposition'] = "attachment; filename=\"#{@file_name}.csv\""
          render 'tracks', layout: false
        end
      end
    end

    def show
      respond_to do |format|
        format.html { render }
        format.json { render json: @conference.tracks.to_json }
      end
    end

    def new
      @track = @program.tracks.new(color: @conference.next_color_for_collection(:tracks))
    end

    def create
      @track = @program.tracks.new(track_params)
      @track.state = 'confirmed'
      @track.cfp_active = true
      if @track.save
        redirect_to admin_conference_program_tracks_path(conference_id: @conference.short_title),
                    notice: 'Track successfully created.'
      else
        flash.now[:error] = "Creating Track failed: #{@track.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def edit; end

    def update
      if @track.update(track_params)
        redirect_to admin_conference_program_tracks_path(conference_id: @conference.short_title),
                    notice: 'Track successfully updated.'
      else
        flash.now[:error] = "Track update failed: #{@track.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @track.destroy
        redirect_to admin_conference_program_tracks_path(conference_id: @conference.short_title),
                    notice: 'Track successfully deleted.'
      else
        redirect_to admin_conference_program_tracks_path(conference_id: @conference.short_title),
                    error: "Track couldn't be deleted. #{@track.errors.full_messages.join('. ')}."
      end
    end

    def toggle_cfp_inclusion
      @track.cfp_active = !@track.cfp_active
      if @track.save
        flash[:notice] = "Successfully changed cfp inclusion of #{@track.name} to #{@track.cfp_active}"
      else
        flash[:error] = "Failed to toggle cfp inclusion of #{@track.name} to #{@track.cfp_active}"
      end

      respond_to do |format|
        format.js
      end
    end

    def restart
      update_state(:restart, "Review for #{@track.name} started!")
    end

    def to_accept
      update_state(:to_accept, "Track #{@track.name} marked as a possible acceptance!")
    end

    def accept
      if @track.room && @track.start_date && @track.end_date
        update_state(:accept, "Track #{@track.name} accepted!")
      else
        flash[:alert] = 'Please make sure that the track has a room and start/end dates before accepting it'
        redirect_to edit_admin_conference_program_track_path(@conference.short_title, @track)
      end
    end

    def confirm
      update_state(:confirm, "Track #{@track.name} confirmed!")
    end

    def to_reject
      update_state(:to_reject, "Track #{@track.name} marked as a possible rejection!")
    end

    def reject
      update_state(:reject, "Track #{@track.name} rejected!")
    end

    def cancel
      update_state(:cancel, "Track #{@track.name} canceled!")
    end

    def update_selected_schedule
      if @track.update(params.require(:track).permit(:selected_schedule_id))
        respond_to do |format|
          format.js { render json: {} }
        end
      else
        respond_to do |format|
          format.js { render json: { errors: "The selected schedule couldn't be updated #{@track.errors.to_a.join('. ')}" }, status: 422 }
        end
      end
    end

    private

    def track_params
      params.require(:track).permit(:name, :description, :color, :short_name, :cfp_active, :start_date, :end_date, :room_id)
    end

    def update_state(transition, notice)
      errors = @track.update_state(transition)

      if errors.blank?
        flash[:notice] = notice
      else
        flash[:error] = errors
      end

      redirect_back_or_to(admin_conference_program_tracks_path(conference_id: @conference.short_title))
    end
  end
end
