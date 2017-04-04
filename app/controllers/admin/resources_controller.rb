module Admin
  class ResourcesController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :resource, only: [:show, :edit, :update, :destroy]
    after_action :prepare_unobtrusive_flash, only: [:update]

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
      successful_update = check_successful_update params[:increment_used_resource_flag]
      respond_to do |format|
        if successful_update
          format.html do
            redirect_to admin_conference_resources_path(conference_id: @conference.short_title),
                        notice: 'Resource successfully updated.'
          end
          flash.now[:notice] = if params[:increment_used_resource_flag].to_i.zero?
                                 "One #{@resource.name} freed."
                               else
                                 "One more #{@resource.name} used."
                               end
        else
          flash.now[:error] = "Resource #{@resource.name}'s update failed: #{@resource.errors.full_messages.join('. ')}."
          format.html{ render :edit }
        end
        format.js
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

    def check_successful_update(increment_used_resource_flag)
      if increment_used_resource_flag.present?
        # Increment/Decrement of Resource via Index Page
        @resource.used = params[:increment_used_resource_flag].to_i == 1 ? (@resource.used + 1) : (@resource.used - 1)
        @resource.save
      else
        # Update via Edit Page
        @resource.update_attributes(resource_params)
      end
    end
  end
end
