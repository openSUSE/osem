module Admin
  class VolunteersController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    authorize_resource class: false, through: :conference

    def index
      render :index
    end

    def show
      if @conference.use_vpositions
        @volunteers = @conference.registrations.joins(:vchoices).uniq
      else
        @volunteers = @conference.registrations.where(volunteer: true)
      end
    end

    def update
      @conference = Conference.find_by(short_title: params[:conference_id])
      begin
        @conference.update_attributes!(params[:conference])
        redirect_to(admin_conference_volunteers_info_path(conference_id: params[:conference_id]), notice: "Volunteering options were successfully updated.")
      rescue => e
        redirect_to(admin_conference_volunteers_info_path(conference_id: params[:conference_id]), alert: "Volunteering options update failed: #{e.message}")
      end
    end
  end
end
