module Admin
  class EventTypesController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :program, through: :conference, singleton: true
    load_and_authorize_resource :event_type, through: :program

    def index; end

    def edit; end

    def new
      @event_type = @conference.program.event_types.new
    end

    def create
      @event_type = @conference.program.event_types.new(event_type_params)
      if @event_type.save
        flash[:notice] = 'Event type successfully created.'
        redirect_to(admin_conference_program_event_types_path(conference_id: @conference.short_title))
      else
        flash[:error] = "Creating event type failed: #{@event_type.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      if @event_type.update_attributes(event_type_params)
        flash[:notice] = 'Event type successfully updated.'
        redirect_to(admin_conference_program_event_types_path(conference_id: @conference.short_title))
      else
        flash[:error] = "Update event type failed: #{@event_type.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @event_type.destroy
        flash[:notice] = 'Event type successfully deleted.'
        redirect_to(admin_conference_program_event_types_path(conference_id: @conference.short_title))
      else
        flash[:error] = 'Destroying event type failed! ' \
        "#{@event_type.errors.full_messages.join('. ')}."
        redirect_to(admin_conference_program_event_types_path(conference_id: @conference.short_title))
      end
    end

    private

    def event_type_params
      params.require(:event_type).permit(:title, :length, :minimum_abstract_length, :maximum_abstract_length, :color, :conference_id, :description)
    end
  end
end
