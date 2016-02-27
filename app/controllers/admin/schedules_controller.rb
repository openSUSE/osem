module Admin
  class SchedulesController < Admin::BaseController
    # By authorizing 'conference' resource, we can ensure there will be no unauthorized access to
    # the schedule of a conference, which should not be accessed in the first place
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :program, through: :conference, singleton: true
    load_resource :venue, through: :conference, singleton: true

    skip_before_filter :verify_authenticity_token, only: [:update]
    layout 'schedule'

    def show
      authorize! :update, @program.events.new
      if @conference.nil?
        redirect_to admin_conference_index_path
        return
      end
      @dates = @conference.start_date..@conference.end_date
      if @venue && @venue.rooms.any?
        @rooms = @venue.rooms
      else
        @rooms = [ Room.new(name: 'No Rooms!', size: 0) ]
      end
    end

    def update
      authorize! :update, @program.events.new
      event = Event.where(guid: params[:event]).first
      error_message = nil
      if event.nil?
        error_message = "Could not find event GUID: #{params[:event]}"
      end

      if params[:date] == 'none'
        event.start_time = nil
        event.room = nil
        event.save!
        render json: { 'status' => 'ok' }
        return
      end
      room = Room.where(guid: room_params).first
      if room.nil?
        error_message = "Could not find room GUID: #{params[:room]}"
      end

      unless error_message.nil?
        render json: { 'status' => 'error', 'message' => error_message }, status: 500
        return
      end

      event.room = room
      time = "#{params[:date]} #{params[:time]}"

      Rails.logger.debug("Loading #{time}")
      # FIXME: Same here as in events_controller.rb. Event timezone should be applied
      # only on output
      # zone = ActiveSupport::TimeZone::new(@conference.timezone)
      # start_time = DateTime.strptime(time + zone.formatted_offset, "%Y-%m-%d %k:%M %Z")
      start_time = DateTime.strptime(time, '%Y-%m-%d %k:%M')
      event.start_time = start_time
      event.save!
      render json: { 'status' => 'ok' }
    end

    private

    def event_params
      params.require(:event).permit(:guid)
    end

    def room_params
      params.require(:room)
    end
  end
end
