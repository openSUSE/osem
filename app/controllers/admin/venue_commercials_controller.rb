# frozen_string_literal: true

module Admin
  class VenueCommercialsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :venue, through: :conference, singleton: true
    load_and_authorize_resource :commercial, through: :venue, singleton: true

    def create
      @commercial = @venue.build_commercial(commercial_params)
      authorize! :create, @commercial

      if @commercial.save
        redirect_to admin_conference_venue_path,
                    notice: 'Materials successfully created.'
      else
        redirect_to admin_conference_venue_path,
                    error: 'An error prohibited materials from being saved: '\
                    "#{@commercial.errors.full_messages.join('. ')}."

      end
    end

    def update
      if @commercial.update(commercial_params)
        redirect_to admin_conference_venue_path,
                    notice: 'Materials successfully updated.'
      else
        redirect_to admin_conference_venue_path,
                    error: 'An error prohibited materials from being saved: '\
                    "#{@commercial.errors.full_messages.join('. ')}."
      end
    end

    def destroy
      @commercial.destroy
      redirect_to admin_conference_venue_path, notice: 'Materials successfully destroyed.'
    end

    def render_commercial
      result = Commercial.render_from_url(params[:url])
      if result[:error]
        render plain: result[:error], status: 400
      else
        render plain: result[:html]
      end
    end

    private

    def commercial_params
      params.require(:commercial).permit(:url)
    end
  end
end
