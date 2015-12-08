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
        flash[:notice] = 'Lodging successfully created.'
        redirect_to admin_conference_lodgings_path(conference_id: @conference.short_title)
      else
        flash[:error] = "Creating Lodging failed: #{@lodging.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def edit; end

    def update
      if @lodging.update_attributes(lodging_params)
        flash[:notice] = 'Lodging successfully updated.'
        redirect_to admin_conference_lodgings_path(conference_id: @conference.short_title)
      else
        flash[:error] = "Update Lodging failed: #{@lodging.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @lodging.destroy
        flash[:notice] = 'Lodging successfully deleted.'
        redirect_to admin_conference_lodgings_path(conference_id: @conference.short_title)
      else
        flash[:error] = 'Deleting lodging failed.' \
                         "#{@lodging.errors.full_messages.join('. ')}."
        redirect_to admin_conference_lodgings_path(conference_id: @conference.short_title)
      end
    end

    private

    def lodging_params
      params[:lodging]
    end
  end
end
