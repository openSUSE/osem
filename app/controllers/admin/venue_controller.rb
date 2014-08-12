module Admin
  class VenueController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :venue, through: :conference, singleton: true

    def index
    end

    def update
      @venue = @conference.venue
      @venue.assign_attributes(params[:venue])
      send_mail = @venue.venue_notify?(@conference)
      if @venue.update_attributes(params[:venue])
        Mailbot.delay.send_email_on_venue_update(@conference) if send_mail
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
end
