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
    supporter = SupporterRegistration.create!(params[:supporter_registration])
    flash[:notice] = "Supporter added"
    render :json => {"status" => "ok"}
  end
end
