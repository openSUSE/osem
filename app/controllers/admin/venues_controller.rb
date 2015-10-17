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
        flash[:notice] = 'Venue was successfully created.'
        redirect_to admin_conference_venue_path
      else
        render :new
      end
    end

    def update
      if @venue.update_attributes(venue_params)
        flash[:notice] = 'Venue was successfully updated.'
        redirect_to admin_conference_venue_path(conference_id: @conference.short_title)
      else
        flash[:error] = "Update venue failed: #{@venue.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @venue.destroy
        flash[:notice] = 'Venue was successfully deleted.'
        redirect_to admin_conference_venue_path
      else
        flash[:error] = 'An error prohibited this Venue from being destroyed: '\
                        "#{@venue.errors.full_messages.join('. ')}."
        redirect_to admin_conference_venue_path
      end
    end

    private

    def venue_params
      params[:venue]
    end
  end
end
