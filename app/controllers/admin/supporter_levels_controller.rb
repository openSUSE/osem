class Admin::SupporterLevelsController < ApplicationController
  before_filter :verify_organizer
  layout "admin"

  def show
    render :supporter_levels
  end

  def update
    begin
      @conference.update_attributes!(params[:conference])
      redirect_to(admin_conference_supporter_levels_path(:conference_id => @conference.short_title), :notice => 'Supporter levels were successfully updated.')
    rescue Exception => e
      redirect_to(admin_conference_supporter_levels_path(:conference_id => @conference.short_title), :alert => "Supporter levels update failed: #{e.message}")
    end
  end
end