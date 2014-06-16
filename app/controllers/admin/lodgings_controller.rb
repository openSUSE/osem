module Admin
  class LodgingsController < ApplicationController
    before_filter :verify_organizer

    def index
      @venue = @conference.venue
    end

    def show
    end

    def update
      @venue = @conference.venue
      if @venue.update_attributes(params[:venue])
        redirect_to(admin_conference_lodgings_path(conference_id: @conference.short_title),
                    notice: 'Lodgings were successfully updated.')
      else
        redirect_to(admin_conference_lodgings_path(conference_id: @conference.short_title),
                    notice: 'Updating lodgings failed!')
      end
    end
  end
end
