module Admin
  class VenuesController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :venue, through: :conference, singleton: true

    def show; end

    def new
      @venue = @conference.build_venue
    end

    def edit; end

    def create
      @venue = @conference.build_venue(venue_params)

      if @venue.save
        redirect_to admin_conference_venue_path,
                    notice: 'Venue was successfully created.'
      else
        render :new
      end
    end

    def update
      if @venue.update_attributes(venue_params)
        redirect_to(admin_conference_venue_path(conference_id: @conference.short_title),
                    notice: 'Venue was successfully updated.')
      else
        flash[:error] = "Update venue failed: #{@venue.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @venue.destroy
        redirect_to admin_conference_venue_path, notice: 'Venue was successfully deleted.'
      else
        redirect_to admin_conference_venue_path, alert: 'An error prohibited this Venue from being destroyed: '\
        "#{@venue.errors.full_messages.join('. ')}."
      end
    end

    private

    def venue_params
      params[:venue]
    end
  end
end
