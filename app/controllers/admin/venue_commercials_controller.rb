module Admin
  class VenueCommercialsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :venue ,through: :conference, singelton: true
    before_action :set_venue
    before_action :set_commercial , only: [:update , :destroy]

    def create
      @commercial = @venue.build_commercial(commercial_params)
      authorize! :create, @commercial

      #FIXME redirect to tab#commercial
      if @commercial.save
        redirect_to edit_admin_conference_venue_path,
                    notice: 'Commercial was successfully created.'
      else
        redirect_to edit_admin_conference_venue_path,
                    error: 'An error prohibited this Commercial from being saved: '\
                    "#{@commercial.errors.full_messages.join('. ')}."

      end
    end

    def update
      if @commercial.update(commercial_params)
        redirect_to edit_admin_conference_venue_path,
                    notice: 'Commercial was successfully updated.'
      else
        redirect_to edit_admin_conference_venue_path,
                    error: 'An error prohibited this Commercial from being saved: '\
                    "#{@commercial.errors.full_messages.join('. ')}."
      end
    end

    def destroy
      @commercial.destroy
      redirect_to edit_admin_conference_venue_path, notice: 'Commercial was successfully destroyed.'
    end

    def render_commercial
      result = Commercial.render_from_url(params[:url])
      if result[:error]
        render text: result[:error], status: 400
      else
        render text: result[:html]
      end
    end

    private

    def commercial_params
      params.require(:commercial).permit(:url)
    end
    
    def set_venue
      @venue = @conference.venue
    end
    
    def set_commercial
      @commercial = Commercial.find params[:id]
    end
  end
end
