module Admin
  class VenuesController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :venue, through: :conference, singleton: true

    def edit; end

    def update
      if @venue.update_attributes(params[:venue])
        redirect_to(edit_admin_conference_venue_path(conference_id: @conference.short_title),
                    notice: 'Venue was successfully updated.')
      else
        flash[:error] = "Update venue failed: #{@venue.errors.full_messages.join('. ')}."
        render :edit
      end
    end

  end
end
