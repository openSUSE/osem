module Admin
  class TargetsController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    authorize_resource :target, through: :conference

    def index
    end

    def update
      if @conference.update_attributes(params[:conference])
        redirect_to(admin_conference_targets_path(
                    conference_id: @conference.short_title),
                    notice: 'Targets were successfully updated.')
      else
        redirect_to(admin_conference_targets_path(
                    conference_id: @conference.short_title),
                    alert: 'Targets update failed: ' \
                    "#{@conference.errors.full_messages.join('. ')}")
      end
    end
  end
end
