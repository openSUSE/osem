class ConferenceController < ApplicationController
  protect_from_forgery with: :null_session
  before_filter :respond_to_options
  load_and_authorize_resource find_by: :short_title
  load_resource :program, through: :conference, singleton: true, except: :index

  def index
    @current = Conference.where('end_date >= ?', Date.current).reorder(start_date: :asc)
    @antiquated = @conferences - @current
  end

  def show; end

  def schedule
    @rooms = @conference.venue.rooms if @conference.venue
    unless @conference.program.events.scheduled.any?
      redirect_to events_conference_path(@conference.short_title)
    end

    @events = @conference.program.events
    @events_xml = @events.scheduled.order(start_time: :asc).group_by{ |event| event.start_time.to_date }
    @dates = @conference.start_date..@conference.end_date
    @step_minutes = EventType::LENGTH_STEP.minutes
    @conf_start = 9
    conf_end = 20
    @conf_period = conf_end - @conf_start
  end

  def events
    @dates = @conference.start_date..@conference.end_date

    @scheduled_events = @conference.program.events.scheduled
    @unscheduled_events = @conference.program.events.unscheduled
  end

  private

  def respond_to_options
    respond_to do |format|
      format.html { head :ok }
    end if request.options?
  end
end
