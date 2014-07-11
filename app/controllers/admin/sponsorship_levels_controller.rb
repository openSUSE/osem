module Admin
  class SponsorshipLevelsController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    authorize_resource :sponsorship_level, through: :conference

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
