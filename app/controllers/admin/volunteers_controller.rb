# frozen_string_literal: true

module Admin
  class VolunteersController < Admin::BaseController
    include VolunteersHelper
    load_and_authorize_resource :conference, find_by: :short_title

    def index
      if can_manage_volunteers?(@conference)
        render :index
      else
        authorize! :index, :volunteer
      end
    end

    def show
      if can_manage_volunteers?(@conference)
        @volunteers = if @conference.use_vpositions
                        @conference.registrations.joins(:vchoices).uniq
                      else
                        @conference.registrations.where(volunteer: true)
                      end
      else
        authorize! :index, :volunteer
      end
    end

    def update
      if @conference.update(conference_params)
        redirect_to admin_conference_volunteers_info_path(conference_id: params[:conference_id]), notice: 'Volunteering options were successfully updated.'
      else
        redirect_to admin_conference_volunteers_info_path(conference_id: params[:conference_id]), error: "Volunteering options update failed: #{@conference.errors.full_messages.join '. '}"
      end
    end

    private

    def conference_params
      params.require(:conference).permit(:use_volunteers, :use_vdays, :use_vpositions)
    end
  end
end
