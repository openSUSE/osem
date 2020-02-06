# frozen_string_literal: true

module Admin
  class EventSchedulesController < Admin::BaseController
    load_and_authorize_resource :event_schedule
    skip_before_action :verify_authenticity_token

    def create
      if @event_schedule.save
        render json: { event_schedule_id: @event_schedule.id }
      else
        render json: { errors: "The event couldn't be scheduled. #{@event_schedule.errors.full_messages.join('. ')}" }, status: 422
      end
    end

    def update
      if @event_schedule.update(event_schedule_params)
        render json: { event_schedule_id: @event_schedule.id }
      else
        render json: { errors: "The event couldn't be scheduled. #{@event_schedule.errors.full_messages.join('. ')}" }, status: 422
      end
    end

    def destroy
      if @event_schedule.destroy
        render json: {}
      else
        render json: { errors: "The event couldn't be unscheduled. #{@event_schedule.errors.full_messages.join('. ')}" }, status: 422
      end
    end

    private

    def event_schedule_params
      params.require(:event_schedule).permit(:schedule_id, :event_id, :room_id, :start_time)
    end
  end
end
