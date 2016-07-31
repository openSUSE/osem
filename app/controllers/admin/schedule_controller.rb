module Admin
  class ScheduleController < Admin::BaseController
    # By authorizing 'conference' resource, we can ensure there will be no unauthorized access to
    # the schedule of a conference, which should not be accessed in the first place
    load_and_authorize_resource :schedule
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :program, through: :conference, singleton: true
    load_resource :venue, through: :conference, singleton: true

    skip_before_action :verify_authenticity_token, only: [:update]

    def index
      @schedules = @conference.program.schedules
      @selected_schedule = @conference.program.selected_schedule
    end

    def create
      new_schedule = @program.schedules.create
      redirect_to action: 'show', id: new_schedule.id
    end

    def show
      @schedule_id = params[:id].to_i
      schedule = Schedule.find(@schedule_id)
      @event_schedules = schedule.event_schedules
      @unscheduled_events = @program.events.confirmed - schedule.events
      @selected_schedule_id = @conference.program.selected_schedule.try(:id)
      @dates = @conference.start_date..@conference.end_date
      @rooms = (@venue && @venue.rooms.any?) ? @venue.rooms : [Room.new(name: 'No Rooms!', size: 0)]
    end

    def update
      if params[:selected_schedule].present?
        if params[:selected_schedule] == 'true'
          @program.selected_schedule_id = params[:id].to_i
        elsif params[:selected_schedule] == 'false' && (@program.selected_schedule_id == params[:id].to_i)
          @program.selected_schedule_id = nil
        end
        @program.save!
        render json: { 'status' => 'ok' }
        return
      end

      event = Event.where(guid: params[:event]).first
      error_message = nil
      if event.nil?
        error_message = "Could not find event GUID: #{params[:event]}"
      end

      event_schedule = event.event_schedules.find_by(schedule_id: params[:schedule])

      if params[:date] == 'none'
        event_schedule.destroy if event_schedule.present?
        render json: { 'status' => 'ok' }
        return
      end

      Rails.logger.debug(event_schedule.present?.to_s)
      event_schedule = event.event_schedules.new(schedule_id: params[:schedule]) unless event_schedule.present?
      room = Room.where(guid: room_params).first

      if room.nil?
        error_message = "Could not find room GUID: #{params[:room]}"
      end

      unless error_message.nil?
        render json: { 'status' => 'error', 'message' => error_message }, status: 500
        return
      end

      event_schedule.room = room
      time = "#{params[:date]} #{params[:time]}"

      Rails.logger.debug("Loading #{time}")
      # FIXME: Same here as in events_controller.rb. Event timezone should be applied
      # only on output
      # zone = ActiveSupport::TimeZone::new(@conference.timezone)
      # start_time = DateTime.strptime(time + zone.formatted_offset, "%Y-%m-%d %k:%M %Z")
      start_time = DateTime.strptime(time, '%Y-%m-%d %k:%M')
      event_schedule.start_time = start_time
      event_schedule.save!
      render json: { 'status' => 'ok' }
    end

    def destroy
      if @schedule.destroy
        redirect_to admin_conference_schedule_index_path(conference_id: @conference.short_title),
                    notice: 'Schedule successfully deleted.'
      else
        redirect_to admin_conference_schedule_index_path(conference_id: @conference.short_title),
                    error: "Schedule couldn't be deleted. #{@schedule.errors.full_messages.join('. ')}."
      end
    end

    private

    def room_params
      params.require(:room)
    end
  end
end
