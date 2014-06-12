module Admin
  class SponsorshipLevelsController < ApplicationController
    before_filter :verify_organizer

    def update
      if @conference.update_attributes(params[:conference])
        redirect_to(admin_conference_sponsorship_levels_path(
                    conference_id: @conference.short_title),
                    notice: 'Sponsorship levels were successfully updated.')
      else
        redirect_to(admin_conference_sponsorship_levels_path(
                    conference_id: @conference.short_title),
                    alert: 'Sponsorship levels update failed')
      end
    end
  end
end
