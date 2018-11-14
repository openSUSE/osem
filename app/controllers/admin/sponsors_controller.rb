# frozen_string_literal: true

module Admin
  class SponsorsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :sponsor, through: :conference
    before_action :sponsorship_level_required, only: [:index, :new]

    def index
      authorize! :index, Sponsor.new(conference_id: @conference.id)
    end

    def edit; end

    def new
      @sponsor = @conference.sponsors.new
    end

    def create
      @sponsor = @conference.sponsors.new(sponsor_params)
      if @sponsor.save
        redirect_to admin_conference_sponsors_path(conference_id: @conference.short_title),
                    notice: 'Sponsor successfully created.'
      else
        flash.now[:error] = "Creating sponsor failed: #{@sponsor.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      if @sponsor.update_attributes(sponsor_params)
        redirect_to admin_conference_sponsors_path(
                    conference_id: @conference.short_title),
                    notice: 'Sponsor successfully updated.'
      else
        flash.now[:error] = "Update sponsor failed: #{@sponsor.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @sponsor.destroy
        redirect_to admin_conference_sponsors_path(conference_id: @conference.short_title),
                    notice: 'Sponsor successfully deleted.'
      else
        redirect_to admin_conference_sponsors_path(conference_id: @conference.short_title),
                    error: 'Deleting sponsor failed! ' \
                    "#{@sponsor.errors.full_messages.join('. ')}."
      end
    end

    private

    def sponsor_params
      params.require(:sponsor).permit(:name, :description, :website_url, :picture, :picture_cache, :sponsorship_level_id, :conference_id)
    end

    def sponsorship_level_required
      return unless @conference.sponsorship_levels.empty?

      redirect_to admin_conference_sponsorship_levels_path(conference_id: @conference.short_title),
                  alert: 'You need to create atleast one sponsorship level to add a sponsor'
    end
  end
end
