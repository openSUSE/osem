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
      end
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
  end
end
