class Admin::VenueController < ApplicationController
  before_filter :verify_organizer

  def index
  end

  def update
    @venue = @conference.venue
    venue_params = params[:venue]
    @venue.name = venue_params[:name]
    @venue.address= venue_params[:address]
    @venue.website = venue_params[:website]
    @venue.description = venue_params[:description]
    @venue.save
    redirect_to(admin_conference_venue_info_path(:conference_id => @conference.short_title), :notice => 'Venue was successfully updated.')
  end

  def show
    @venue = @conference.venue
    render :venue_info
  end

end
