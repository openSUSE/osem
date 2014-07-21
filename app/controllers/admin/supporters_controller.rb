class Admin::SupportersController < ApplicationController
  before_filter :verify_organizer

  def index
    respond_to do |format|
      format.html
      format.json { render json: DatatableSupporters.new(@conference.supporter_registrations, view_context) }
    end
  end

  def create
    params[:supporter_registration][:conference_id] = @conference.id
    SupporterRegistration.create!(params[:supporter_registration])
    redirect_to(admin_conference_supporters_path(conference_id: @conference.short_title), notice: "Supporter added")
  end
end
