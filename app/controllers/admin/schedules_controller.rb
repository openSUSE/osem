module Admin
  class SchedulesController < Admin::BaseController
    # By authorizing 'conference' resource, we can ensure there will be no unauthorized access to
    # the schedule of a conference, which should not be accessed in the first place
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :program, through: :conference, singleton: true
    load_and_authorize_resource :schedule, through: :program
    load_resource :event_schedules, through: :schedule
    load_resource :selected_schedule, through: :program, singleton: true
    load_resource :venue, through: :conference, singleton: true

    def index; end

    def create
      if @schedule.save
        redirect_to admin_conference_schedule_path(@conference.short_title, @schedule.id),
                    notice: 'Schedule was successfully created.'
      else
        redirect_to admin_conference_schedules_path(conference_id: @conference.short_title),
                    error: "Could not create schedule. #{@schedule.errors.full_messages.join('. ')}."
      end
    end

    def show
      @event_schedules = @schedule.event_schedules
      @unscheduled_events = @program.events.confirmed - @schedule.events
      @dates = @conference.start_date..@conference.end_date
      @rooms = @conference.venue.rooms if @conference.venue
    end

    def destroy
      if @schedule.destroy
        redirect_to admin_conference_schedules_path(conference_id: @conference.short_title),
                    notice: 'Schedule successfully deleted.'
      else
        redirect_to admin_conference_schedules_path(conference_id: @conference.short_title),
                    error: "Schedule couldn't be deleted. #{@schedule.errors.full_messages.join('. ')}."
      end
    end
  end
end
