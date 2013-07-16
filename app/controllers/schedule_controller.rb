class ScheduleController < ApplicationController

  layout "application"
  
  def index
    @conference = Conference.includes(:rooms, {:events => [:speakers, :track, :event_type]}).where("conferences.short_title" => params[:conference_id]).first
    @rooms = @conference.rooms
    @events = @conference.events
    @dates = @conference.start_date..@conference.end_date
    end

end
