class Admin::RoomsController < ApplicationController
  before_filter :verify_organizer

  def show
    render :rooms_list
  end

  def update
    if @conference.update_attributes(params[:conference])
      redirect_to(admin_conference_rooms_list_path(:conference_id => @conference.short_title), :notice => 'Rooms were successfully updated.')
    else
      redirect_to(admin_conference_rooms_list_path(:conference_id => @conference.short_title), :notice => 'Room update failed.')
    end

  end

end
