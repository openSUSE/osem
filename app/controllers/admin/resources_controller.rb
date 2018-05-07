# frozen_string_literal: true

module Admin
  class ResourcesController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :resource, only: [:show, :edit, :update, :destroy]

    def index; end

    def edit; end

    def new
      @resource = @conference.resources.new
    end

    def create
      @resource = @conference.resources.new(resource_params)
      if @resource.save
        redirect_to admin_conference_resources_path(conference_id: @conference.short_title),
                    notice: 'Resource successfully created.'
      else
        flash.now[:error] = "Creating resource failed: #{@resource.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      if @resource.update_attributes(resource_params)
        redirect_to admin_conference_resources_path(conference_id: @conference.short_title),
                    notice: 'Resource successfully updated.'
      else
        flash.now[:error] = "Resource update failed: #{@resource.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @resource.destroy
        redirect_to admin_conference_resources_path(conference_id: @conference.short_title),
                    notice: 'Resource successfully destroyed.'
      else
        redirect_to admin_conference_resources_path(conference_id: @conference.short_title),
                    error: 'Resource was successfully destroyed.' \
  	                "#{@resource.errors.full_messages.join('. ')}."
      end
    end

    private

    def resource_params
      params.require(:resource).permit(:name, :description, :quantity, :used, :conference_id)
    end
  end
end
