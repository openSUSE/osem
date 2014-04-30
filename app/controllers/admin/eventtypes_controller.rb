class Admin::EventtypesController < ApplicationController
  before_filter :verify_organizer

  def show
    render :eventtypes
  end

  def update
    @conference.update_attributes!(params[:conference])
    redirect_to(admin_conference_eventtypes_path(
                conference_id: @conference.short_title),
                notice: 'Event types were successfully updated.')
  rescue Exception => e
    redirect_to(admin_conference_eventtypes_path(
                conference_id: @conference.short_title),
                alert: 'Event types update failed: #{e.message}')
  end
end
