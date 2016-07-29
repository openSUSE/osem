class SchedulesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :respond_to_options
  load_and_authorize_resource :conference, find_by: :short_title
  load_resource :program, through: :conference, singleton: true, except: :index

  def show
    @rooms = @conference.venue.rooms if @conference.venue
    unless @program.selected_schedule.present? && @program.events.scheduled(@program.selected_schedule.id).any?
      redirect_to events_conference_schedule_path(@conference.short_title)
    end

    schedules = @program.selected_event_schedules
    @events_xml = schedules.map(&:event).group_by{ |event| event.scheduled_start_time.to_date } if schedules
    @dates = @conference.start_date..@conference.end_date
    @step_minutes = EventType::LENGTH_STEP.minutes
    @conf_start = 9
    conf_end = 20
    @conf_period = conf_end - @conf_start

    # the schedule takes you to today if it is a date of the schedule
    @current_day = @conference.current_conference_day
    @day = @current_day.present? ? @current_day : @dates.first
    return unless @current_day
    # the schedule takes you to the current time if it is beetween the start and the end time.
    @hour_column = @conference.hours_from_start_time(@conf_start, conf_end)
  end

  def events
    @dates = @conference.start_date..@conference.end_date

    @events_schedules = @program.selected_event_schedules
    @events_schedules = [] unless @events_schedules

    @unscheduled_events = @program.events.unscheduled(@program.selected_schedule.id)

    day = @conference.current_conference_day
    @tag = day.strftime('%Y-%m-%d') if day
  end

  private

  def respond_to_options
    respond_to do |format|
      format.html { head :ok }
    end if request.options?
  end
end
