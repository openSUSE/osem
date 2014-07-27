module Admin
  class SponsorsController < ApplicationController
    before_filter :verify_organizer

    def update
      if @conference.update_attributes(params[:conference])
        redirect_to(admin_conference_sponsors_path(
                    conference_id: @conference.short_title),
                    notice: 'Sponsorships were successfully updated.')
      else
        redirect_to(admin_conference_sponsors_path(
                    conference_id: @conference.short_title),
                    alert: 'Sponsorships update failed.')
      end
    end
  end
end
