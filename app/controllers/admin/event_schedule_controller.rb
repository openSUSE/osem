module Admin
  class EventScheduleController < Admin::BaseController
    load_and_authorize_resource :event_schedule

    def create
      event_schedule = EventSchedule.create(get_event_schedule_params(params))
      render json: { 'status' => 'ok', event_schedule_id: event_schedule.id }
    end

    def update
      @event_schedule.update(get_event_schedule_params(params))
      render json: { 'status' => 'ok', event_schedule_id: @event_schedule.id }
    end

    def destroy
      @event_schedule.destroy if @event_schedule
      render json: { 'status' => 'ok' }
    end

    private

    def get_event_schedule_params(params)
      error_message = nil

      event = Event.where(guid: params[:event]).first
      error_message = "Could not find event GUID: #{params[:event]}" if event.nil?

      schedule = Schedule.where(id: params[:schedule]).first
      error_message = "Could not find schedule: #{params[:schedule]}" if schedule.nil?

      room = Room.where(guid: params[:room]).first
      error_message = "Could not find room GUID: #{params[:room]}" if room.nil?

      error_message = 'Date and time must be present' if params[:date].eql?('') || params[:time].eql?('')

      unless error_message.nil?
        render json: { 'status' => 'error', 'message' => error_message }, status: 500
        return
      end

      time = "#{params[:date]} #{params[:time]}"
      Rails.logger.debug("Loading #{time}")
      start_time = DateTime.strptime(time, '%Y-%m-%d %k:%M')
      { schedule: schedule, event: event, room: room, start_time: start_time }
    end
  end
end
