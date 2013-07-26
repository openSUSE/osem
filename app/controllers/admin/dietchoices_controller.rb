class Admin::DietchoicesController < ApplicationController
  before_filter :verify_organizer

  def show
    render :diets_list
  end

  def update
    begin
      @conference.update_attributes!(params[:conference])
      redirect_to(admin_conference_dietary_list_path(:conference_id => @conference.short_title), :notice => 'Dietary choices were successfully updated.')
    rescue Exception => e
      redirect_to(admin_conference_dietary_list_path(:conference_id => @conference.short_title), :alert => "Dietary choices update failed: #{e.message}")
    end
  end
end