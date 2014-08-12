module Admin
  class SponsorsController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    authorize_resource :sponsor, through: :conference

    def index
      authorize! :index, Sponsor.new(conference_id: @conference.id)
    end

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
