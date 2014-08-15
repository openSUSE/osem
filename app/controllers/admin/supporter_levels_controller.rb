module Admin
  class SupporterLevelsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    authorize_resource through: :conference

    def index
      authorize! :update, SupporterLevel.new(conference_id: @conference.id)
    end

    def show
      render :supporter_levels
    end

    def update
      begin
        @conference.update_attributes!(params[:conference])
        redirect_to(admin_conference_supporter_levels_path(conference_id: @conference.short_title), notice: 'Supporter levels were successfully updated.')
      rescue => e
        redirect_to(admin_conference_supporter_levels_path(conference_id: @conference.short_title), alert: "Supporter levels update failed: #{e.message}")
      end
    end
  end
end
