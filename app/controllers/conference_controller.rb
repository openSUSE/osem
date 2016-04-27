class ConferenceController < ApplicationController
  protect_from_forgery with: :null_session
  before_filter :respond_to_options
  load_and_authorize_resource find_by: :short_title
  load_resource :program, through: :conference, singleton: true, except: :index

  def index
    @current = Conference.where('end_date >= ?', Date.current).order('start_date ASC')
    @antiquated = @conferences - @current
  end

  def show; end

  def schedule
    @rooms = @conference.venue.rooms if @conference.venue
    @events = @conference.program.events
    @dates = @conference.start_date..@conference.end_date

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
