# frozen_string_literal: true

module Admin
  class SplashpagesController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource through: :conference, singleton: true

    def show; end

    def new
      @splashpage = @conference.build_splashpage
    end

    def edit; end

    def create
      @splashpage = @conference.build_splashpage(splashpage_params)

      if @splashpage.save
        redirect_to admin_conference_splashpage_path,
                    notice: 'Splashpage successfully created.'
      else
        render :new
      end
    end

    def update
      if @splashpage.update_attributes(splashpage_params)
        redirect_to admin_conference_splashpage_path,
                    notice: 'Splashpage successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      if @splashpage.destroy
        redirect_to admin_conference_splashpage_path, notice: 'Splashpage was successfully destroyed.'
      else
        redirect_to admin_conference_splashpage_path, error: 'An error prohibited this Splashpage from being destroyed: '\
        "#{@splashpage.errors.full_messages.join('. ')}."
      end
    end

    private

    def splashpage_params
      params.require(:splashpage).permit(:public,
                                         :include_tracks, :include_program, :include_cfp,
                                         :include_venue, :include_registrations,
                                         :include_tickets, :include_lodgings,
                                         :include_sponsors, :include_social_media,
                                         :include_booths)
    end
  end
end
