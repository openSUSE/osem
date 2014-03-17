class Admin::VolunteersController < ApplicationController
  def index
    @conference = Conference.find_all_by_short_title(params[:conference_id]).first
    render :index
  end
  
  def show
    @conference = Conference.find_all_by_short_title(params[:conference_id]).first
    if @conference.use_vpositions
      @volunteers = @conference.registrations.joins(:vchoices).uniq
    else
      @volunteers = @conference.registrations.where(:volunteer => true)
    end
  end

  def update
    @conference = Conference.find_all_by_short_title(params[:conference_id]).first
    begin
      @conference.update_attributes!(params[:conference])
      redirect_to(admin_conference_volunteers_info_path(:conference_id => params[:conference_id]), :notice => "Volunteering options were successfully updated.")
    rescue Exception => e
      redirect_to(admin_conference_volunteers_info_path(:conference_id => params[:conference_id]), :alert => "Volunteering options update failed: #{e.message}")
    end
  end
end
