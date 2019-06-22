# frozen_string_literal: true

module Admin
  class TrackTypesController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :program, through: :conference, singleton: true
    load_and_authorize_resource :track_type, through: :program

    def index; end

    def edit; end

    def new
      @track_type = @conference.program.track_types.new
    end

    def create
      @track_type = @conference.program.track_types.new(track_type_params)
      if @track_type.save
        redirect_to admin_conference_program_track_types_path(conference_id: @conference),
                    notice: 'Track type successfully created.'
      else
        flash.now[:error] = "Creating track type failed: #{@track_type.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      if @track_type.update_attributes(track_type_params)
        redirect_to admin_conference_program_track_types_path(conference_id: @conference),
                    notice: 'Track type successfully updated.'
      else
        flash.now[:error] = "Update track type failed: #{@track_type.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @track_type.destroy
        redirect_to admin_conference_program_track_types_path(conference_id: @conference),
                    notice: 'Track type successfully deleted.'
      else
        redirect_to admin_conference_program_track_types_path(conference_id: @conference),
                    error: 'Destroying track type failed! '\
                    "#{@track_type.errors.full_messages.join('. ')}."
      end
    end

    private

    def track_type_params
      params.require(:track_type).permit(:title, :description)
    end
  end
end
