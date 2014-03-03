class Admin::VolunteersController < ApplicationController
  def index
    @conference = Conference.find_all_by_short_title(params[:conference_id]).first
    render :index
  end
  
  def show
    @conference = Conference.find_all_by_short_title(params[:conference_id]).first
    @volunteers = @conference.registrations.joins(:vchoices).all
  end

  def update
    @conference = Conference.find_all_by_short_title(params[:conference_id]).first
#     @conference.update_attributes(params[:conference])
#     redirect_to admin_conference_volunteers_path(@conference.short_title)
        begin
      @conference.update_attributes!(params[:conference])
       redirect_to(admin_conference_volunteer_options_path(:conference_id => params[:conference_id]), :notice => "Volunteering options were successfully updated.")
        rescue Exception => e
          redirect_to(admin_conference_volunteer_options_path(:conference_id => params[:conference_id]), :alert => "Volunteering options update failed: #{e.message}")
    end
  end
end
