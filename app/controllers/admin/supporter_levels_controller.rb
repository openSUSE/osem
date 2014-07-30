module Admin
  class Admin::SupporterLevelsController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    authorize_resource :supporter_level, through: :conference

    def show
      render :supporter_levels
    end

    def update
      @conference.update_attributes!(params[:conference])
      redirect_to(admin_conference_supporter_levels_path(conference_id: @conference.short_title), notice: 'Supporter levels were successfully updated.')
    rescue => e
      redirect_to(admin_conference_supporter_levels_path(conference_id: @conference.short_title), alert: "Supporter levels update failed: #{e.message}")
    end
  end
end
