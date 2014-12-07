module Admin
  class EventTypesController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :event_type, through: :conference

    def index
      authorize! :index, EventType.new(conference_id: @conference.id)
    end

    def edit; end

    def new
      @event_type = @conference.event_types.new
    end

    def create
      @event_type = @conference.event_types.new(event_type_params)
      if @event_type.save
        redirect_to(admin_conference_event_types_path(conference_id: @conference.short_title),
                    notice: 'Event type successfully created.')
      else
        flash[:error] = "Creating event type failed: #{@event_type.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      if @event_type.update_attributes(event_type_params)
        redirect_to(admin_conference_event_types_path(
                    conference_id: @conference.short_title),
                    notice: 'Event type successfully updated.')
      else
        flash[:error] = "Update event type failed: #{@event_type.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @event_type.destroy
        redirect_to(admin_conference_event_types_path(conference_id: @conference.short_title),
                    notice: 'Event type successfully deleted.')
      else
        redirect_to(admin_conference_event_types_path(conference_id: @conference.short_title),
                    error: 'Destroying event type failed! ' \
                    "#{@event_type.errors.full_messages.join('. ')}.")
      end
    end

    private

    def event_type_params
      params.require(:event_type).permit(:title, :length,
                                         :minimum_abstract_length,
                                         :maximum_abstract_length,
                                         :color, :is_keynote)
    end
  end
end
