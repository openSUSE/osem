class ScheduleController < ApplicationController

  layout "application"
  caches_page :index
  
  def index
    @conference = Conference.find_all_by_short_title(params[:conference_id]).first
    @events = @conference.events
    @dates = @conference.start_date..@conference.end_date
    @rooms = @conference.rooms
    end

end
