class Admin::SponsorshipLevelsController < ApplicationController
  before_filter :verify_organizer

  def show
    render :sponsorship_levels
  end

  def update
    begin
      @conference.update_attributes!(params[:conference])
      redirect_to(admin_conference_sponsorship_levels_path(:conference_id => @conference.short_title), :notice => 'Sponsorship levels were successfully updated.')
    rescue Exception => e
      redirect_to(admin_conference_sponsorship_levels_path(:conference_id => @conference.short_title), :alert => "Sponsorship levels update failed: #{e.message}")
    end
  end
end
