module Admin
  class VenueController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :venue, through: :conference, singleton: true

    def index
    end

    def update
      @venue = @conference.venue
      @venue.assign_attributes(params[:venue])
      unless @venue.name.blank? || @venue.address.blank? || @conference.registrations.blank?
        if (@venue.name_changed? ||
            @venue.address_changed?) &&
                (@conference.email_settings.send_on_venue_update &&
                !@conference.email_settings.venue_update_subject.blank? &&
                @conference.email_settings.venue_update_template)
          venue_notify = Mailbot.send_email_on_venue_update(@conference)
        end
      end

      if @venue.update_attributes(params[:venue])
        venue_notify.deliver unless venue_notify.blank?
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
