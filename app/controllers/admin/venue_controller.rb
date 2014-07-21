class Admin::VenueController < ApplicationController
  before_filter :verify_organizer

  def index
  end

  def update
    @venue = @conference.venue
    if @venue.update_attributes!(params[:venue])
      redirect_to(admin_conference_venue_info_path(conference_id: @conference.short_title),
                  notice: 'Venue was successfully updated.')
    else
      redirect_to(admin_conference_venue_info_path(conference_id: @conference.short_title),
                  notice: 'Venue Updation Failed!')
    end
  end

  def show
    @venue = @conference.venue
    render :venue_info
  end
end
