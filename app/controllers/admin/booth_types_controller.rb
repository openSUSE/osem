# frozen_string_literal: true

module Admin
  class BoothTypesController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :program, through: :conference, singleton: true
    load_and_authorize_resource :booth_type, through: :program

    def index; end

    def edit; end

    def new
      @booth_type = @conference.program.booth_types.new
    end

    def create
      @booth_type = @conference.program.booth_types.new(booth_type_params)
      if @booth_type.save
        redirect_to admin_conference_program_booth_types_path(conference_id: @conference),
                    notice: "#{(t'booth').capitalize} type successfully created."
      else
        flash.now[:error] = "Creating #{t 'booth'} type failed: #{@booth_type.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      if @booth_type.update_attributes(booth_type_params)
        redirect_to admin_conference_program_booth_types_path(conference_id: @conference),
                    notice: "#{(t'booth').capitalize} type successfully updated."
      else
        flash.now[:error] = "Update #{t 'booth'} type failed: #{@booth_type.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @booth_type.destroy
        redirect_to admin_conference_program_booth_types_path(conference_id: @conference),
                    notice: "#{(t'booth').capitalize} type successfully deleted."
      else
        redirect_to admin_conference_program_booth_types_path(conference_id: @conference),
                    error: "Destroying #{t 'booth'} type failed! "\
                    "#{@booth_type.errors.full_messages.join('. ')}."
      end
    end

    private

    def booth_type_params
      params.require(:booth_type).permit(:title, :description)
    end
  end
end
