module Admin
  class LodgingsController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    authorize_resource :lodging, through: :conference

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
