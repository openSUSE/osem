module Admin
  class RoomsController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    authorize_resource :room, through: :conference

    def show
      render :rooms_list
    end

    def update
      if @conference.update_attributes(params[:conference])
        redirect_to(admin_conference_rooms_path(
                    conference_id: @conference.short_title),
                    notice: 'Rooms were successfully updated.')
      else
        redirect_to(admin_conference_rooms_path(
                    conference_id: @conference.short_title),
                    notice: 'Room update failed.')
      end
    end
  end
end
