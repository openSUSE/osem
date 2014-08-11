module Admin
  class VenueController < ApplicationController
    before_filter :verify_organizer

    def index
    end

    def update
      @venue = @conference.venue
      @venue.assign_attributes(params[:venue])
      venue_notify = (@venue.name_changed? || @venue.address_changed?) &&
                     (!@venue.name.blank? && !@venue.address.blank?) &&
                     (@conference.email_settings.send_on_venue_update &&
                     !@conference.email_settings.venue_update_subject.blank? &&
                     @conference.email_settings.venue_update_template)

      if @venue.update_attributes(params[:venue])
        Mailbot.delay.send_email_on_venue_update(@conference) if venue_notify
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
