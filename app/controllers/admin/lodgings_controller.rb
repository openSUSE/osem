# frozen_string_literal: true

module Admin
  class LodgingsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :lodging, through: :conference

    def index
    end

    def new
      @lodging = @conference.lodgings.new
    end

    def create
      @lodging = @conference.lodgings.new(lodging_params)
      if @lodging.save
        redirect_to admin_conference_lodgings_path(conference_id: @conference.short_title),
                    notice: 'Lodging successfully created.'
      else
        flash.now[:error] = "Creating Lodging failed: #{@lodging.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def edit; end

    def update
      if @lodging.update(lodging_params)
        redirect_to admin_conference_lodgings_path(conference_id: @conference.short_title),
                    notice: 'Lodging successfully updated.'
      else
        flash.now[:error] = "Update Lodging failed: #{@lodging.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @lodging.destroy
        redirect_to admin_conference_lodgings_path(conference_id: @conference.short_title),
                    notice: 'Lodging successfully deleted.'
      else
        redirect_to admin_conference_lodgings_path(conference_id: @conference.short_title),
                    error: 'Deleting lodging failed.' \
                    "#{@lodging.errors.full_messages.join('. ')}."
      end
    end

    private

    def lodging_params
      params.require(:lodging).permit(:name, :description, :picture, :picture_cache, :website_link, :conference_id)
    end
  end
end
