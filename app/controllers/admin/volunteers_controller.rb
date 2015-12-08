module Admin
  class VolunteersController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title

    def index
      if can_manage_volunteers(@conference)
        render :index
      else
        authorize! :index, :volunteer
      end
    end

    def show
      if can_manage_volunteers(@conference)
        if @conference.use_vpositions
          @volunteers = @conference.registrations.joins(:vchoices).uniq
        else
          @volunteers = @conference.registrations.where(volunteer: true)
        end
      else
        authorize! :index, :volunteer
      end
    end

    def update
      if can_manage_volunteers(@conference)
        if @conference.update_attributes(params[:conference])
          flash[:notice] = 'Volunteering options were successfully updated.'
          redirect_to admin_conference_volunteers_info_path(conference_id: params[:conference_id])
        else
          flash[:error] = "Volunteering options update failed: #{@conference.errors.full_messages.join '. '}"
          redirect_to admin_conference_volunteers_info_path(conference_id: params[:conference_id])
        end
      else
        authorize! :index, :volunteer
      end
    end
  end
end
