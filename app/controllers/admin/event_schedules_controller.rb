module Admin
  class EventSchedulesController < Admin::BaseController
    load_and_authorize_resource :event_schedule

    def create
      @event_schedule.save
      render json: { 'status' => 'ok', event_schedule_id: @event_schedule.id }
    end

    def update
      @event_schedule.update(event_schedule_params)
      render json: { 'status' => 'ok', event_schedule_id: @event_schedule.id }
    end

    def destroy
      @event_schedule.destroy
      render json: { 'status' => 'ok' }
    end

    private

    def event_schedule_params
      params.require(:event_schedule).permit(:schedule_id, :event_id, :room_id, :start_time)
    end
  end
end
