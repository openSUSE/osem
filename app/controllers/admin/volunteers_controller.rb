module Admin
  class VolunteersController < ApplicationController
    def index
      @conference = Conference.find_by(short_title: params[:conference_id])
      render :index
    end

    def show
      @conference = Conference.find_by(short_title: params[:conference_id])
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
