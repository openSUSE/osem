class ConferenceController < ApplicationController
  before_filter :respond_to_options
  load_and_authorize_resource find_by: :short_title

  def index
    @current = Conference.where('end_date >= ?', Date.current).order('start_date ASC')
    @antiquated = @conferences - @current
  end

  def show; end

  def schedule
    @rooms = @conference.rooms
    @events = @conference.events
    @dates = @conference.start_date..@conference.end_date

    if @dates == Date.current
      @today = Date.current.strftime('%Y-%m-%d')
    else
      @today = @conference.start_date.strftime('%Y-%m-%d')
    end
  end

  def gallery_photos
    @photos = @conference.photos
    render 'photos', formats: [:js]
  end

  private

  def respond_to_options
    respond_to do |format|
      format.html { head :ok }
    end if request.options?
  end
end
