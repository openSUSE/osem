# frozen_string_literal: true

module Admin
  class SponsorshipLevelsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource through: :conference

    def index
      authorize! :index, SponsorshipLevel.new(conference_id: @conference.id)
    end

    def edit; end

    def new
      @sponsorship_level = @conference.sponsorship_levels.new
    end

    def create
      @sponsorship_level = @conference.sponsorship_levels.new(sponsorship_level_params)
      if @sponsorship_level.save
        redirect_to admin_conference_sponsorship_levels_path(conference_id: @conference.short_title),
                    notice: 'Sponsorship level successfully created.'
      else
        flash.now[:error] = "Creating Sponsorship Level failed: #{@sponsorship_level.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      if @sponsorship_level.update_attributes(sponsorship_level_params)
        redirect_to admin_conference_sponsorship_levels_path(
                    conference_id: @conference.short_title),
                    notice: 'Sponsorship level successfully updated.'
      else
        flash.now[:error] = "Update Sponsorship level failed: #{@sponsorship_level.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @sponsorship_level.destroy
        redirect_to admin_conference_sponsorship_levels_path(conference_id: @conference.short_title),
                    notice: 'Sponsorship level successfully deleted.'
      else
        redirect_to admin_conference_sponsorship_levels_path(conference_id: @conference.short_title),
                    error: 'Deleting sponsorship level failed! ' \
                    "#{@sponsorship_level.errors.full_messages.join('. ')}."
      end
    end

    def up
      @sponsorship_level.move_higher
      redirect_to admin_conference_sponsorship_levels_path(conference_id: @conference.short_title)
    end

    def down
      @sponsorship_level.move_lower
      redirect_to admin_conference_sponsorship_levels_path(conference_id: @conference.short_title)
    end

    private

    def sponsorship_level_params
      params.require(:sponsorship_level).permit(:title, :conference_id)
    end
  end
end
