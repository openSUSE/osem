class Admin::TracksController < ApplicationController
  before_filter :verify_organizer

  def show
    respond_to do |format|
      format.html { render :tracks_list}
      format.json { render :json => @conference.tracks.to_json }
    end
  end

  def update
    if @conference.update_attributes(params[:conference])
      redirect_to(admin_conference_tracks_list_path(:conference_id => @conference.short_title), :notice => 'Tracks were successfully updated.')
    else
      redirect_to(admin_conference_tracks_list_path(:conference_id => @conference.short_title), :notice => 'Tracks update failed.')
    end

  end

end
