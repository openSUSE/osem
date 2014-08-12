module Admin
  class LodgingsController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :venue, through: :conference, singleton: true
    authorize_resource :lodging, through: :venue

    def index
      authorize! :update, Lodging.new(venue_id: @venue.id)
    end

    def show
    end

    def update
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
