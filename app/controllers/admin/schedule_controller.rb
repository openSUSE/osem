class Admin::ScheduleController < ApplicationController
  before_filter :verify_organizer
  layout "schedule"

  def show
    @dates = @conference.start_date..@conference.end_date
    @tracks = @conference.tracks
  end

  def update

  end
end