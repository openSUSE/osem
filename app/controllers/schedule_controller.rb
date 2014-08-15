class ScheduleController < ApplicationController
  authorize_resource class: false
  layout "application"

  def index
    @conference = Conference.includes(:rooms, events: [:speakers, :track, :event_type]).where("conferences.short_title" => params[:conference_id]).first
    @rooms = @conference.rooms
    @events = @conference.events
    @dates = @conference.start_date..@conference.end_date

    if @dates == Date.current
      @today = Date.current.strftime("%Y-%m-%d")
    else
      @today = @conference.start_date.strftime("%Y-%m-%d")
    end
  end
end
