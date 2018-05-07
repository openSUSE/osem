# frozen_string_literal: true

class SchedulesController < ApplicationController
  load_and_authorize_resource
  protect_from_forgery with: :null_session
  before_action :respond_to_options
  load_resource :conference, find_by: :short_title
  load_resource :program, through: :conference, singleton: true, except: :index

  def show
    @rooms = @conference.venue.rooms if @conference.venue
    schedules = @program.selected_event_schedules
    unless schedules
      redirect_to events_conference_schedule_path(@conference.short_title)
    end

    @events_xml = schedules.map(&:event).group_by{ |event| event.time.to_date } if schedules
    @dates = @conference.start_date..@conference.end_date
    @step_minutes = @program.schedule_interval.minutes
    @conf_start = @conference.start_hour
    @conf_period = @conference.end_hour - @conf_start

    # the schedule takes you to today if it is a date of the schedule
    @current_day = @conference.current_conference_day
    @day = @current_day.present? ? @current_day : @dates.first
    unless @current_day
      # the schedule takes you to the current time if it is beetween the start and the end time.
      @hour_column = @conference.hours_from_start_time(@conf_start, @conference.end_hour)
    end
    # Ids of the schedules of confrmed self_organized tracks along with the selected_schedule_id
    @selected_schedules_ids = [@conference.program.selected_schedule_id]
    @conference.program.tracks.self_organized.confirmed.each do |track|
      @selected_schedules_ids << track.selected_schedule_id
    end
    @selected_schedules_ids.compact!
  end

  def events
    @dates = @conference.start_date..@conference.end_date

    @events_schedules = @program.selected_event_schedules
    @events_schedules = [] unless @events_schedules

    @unscheduled_events = @program.events.confirmed - @events_schedules.map(&:event)

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
