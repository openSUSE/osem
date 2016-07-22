module Admin
  class EventSchedulesController < Admin::BaseController
    load_and_authorize_resource :event_schedule

    def create
      if @event_schedule.save
        render json: { event_schedule_id: @event_schedule.id }
      else
        render json: { errors: parse_errors(@event_schedule) }, status: 422
      end
    end

    def update
      if @event_schedule.update(event_schedule_params)
        render json: { event_schedule_id: @event_schedule.id }
      else
        render json: { errors: parse_errors(@event_schedule) }, status: 422
      end
    end

    def destroy
      if @event_schedule.destroy
        render json: {}
      else
        render json: { errors: parse_errors(@event_schedule) }, status: 422
      end
    end

    private

    def event_schedule_params
      params.require(:event_schedule).permit(:schedule_id, :event_id, :room_id, :start_time)
    end

    def parse_errors(event_schedule)
      title = event_schedule.event.try(:title).present? ? event_schedule.event.title : 'The event'
      errors = event_schedule.errors.full_messages.present? ? " (#{event_schedule.errors.full_messages.join('. ')})" : ''
      "#{title} couldn't be scheduled#{errors}. "
    end
  end
end
