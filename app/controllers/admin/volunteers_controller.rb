module Admin
  class VolunteersController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title

    def index
      if (current_user.has_role? :organizer, @conference) || (current_user.has_role? :volunteer_coordinator, @conference)
        render :index
      else
        authorize! :index, :volunteer
      end
    end

    def show
      if (current_user.has_role? :organizer, @conference) || (current_user.has_role? :volunteer_coordinator, @conference)
        if @conference.use_vpositions
          @volunteers = @conference.registrations.joins(:vchoices).uniq
        else
          @volunteers = @conference.registrations.where(:volunteer => true)
        end
      else
        authorize! :index, :volunteer
      end
    end

    def update
      if (current_user.has_role? :organizer, @conference) || (current_user.has_role? :volunteer_coordinator, @conference)
        begin
          @conference.update_attributes!(params[:conference])
          redirect_to(admin_conference_volunteers_info_path(:conference_id => params[:conference_id]), :notice => "Volunteering options were successfully updated.")
        rescue Exception => e
          redirect_to(admin_conference_volunteers_info_path(:conference_id => params[:conference_id]), :alert => "Volunteering options update failed: #{e.message}")
        end
      else
        authorize! :index, :volunteer
      end
    end
  end
end
