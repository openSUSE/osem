module Admin
  class SupportersController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource through: :conference

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
end
