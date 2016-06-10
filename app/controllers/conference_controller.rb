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
    @events = @conference.program.events
    @events_xml = @events.scheduled.order(start_time: :asc).group_by{ |event| event.start_time.to_date }
    @dates = @conference.start_date..@conference.end_date

    @number_columns = 1
    @conf_start = 9
    conf_end = 20
    @intervals = @number_columns * 60 / EventType::LENGTH_STEP + 1
    @width = 85 / @intervals
    @step_minutes = EventType::LENGTH_STEP.minutes
    @carousel_number = ((conf_end - @conf_start) / @number_columns.to_f).ceil

    if @dates == Date.current
      @today = Date.current.strftime('%Y-%m-%d')
    else
      @today = @conference.start_date.strftime('%Y-%m-%d')
    end
  end

  private

  def respond_to_options
    respond_to do |format|
      format.html { head :ok }
    end if request.options?
  end
end
