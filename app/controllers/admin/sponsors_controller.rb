module Admin
  class SponsorsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :sponsor, through: :conference

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
        flash[:notice] = 'Sponsor successfully created.'
        redirect_to admin_conference_sponsors_path(conference_id: @conference.short_title)
      else
        flash[:error] = "Creating sponsor failed: #{@sponsor.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      if @sponsor.update_attributes(sponsor_params)
        flash[:notice] = 'Sponsor successfully updated.'
        redirect_to admin_conference_sponsors_path(conference_id: @conference.short_title)
      else
        flash[:error] = "Update sponsor failed: #{@sponsor.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @sponsor.destroy
        flash[:notice] = 'Sponsor successfully deleted.'
        redirect_to admin_conference_sponsors_path(conference_id: @conference.short_title)
      else
        flash[:error] = 'Deleting sponsor failed! ' \
                        "#{@sponsor.errors.full_messages.join('. ')}."
        redirect_to admin_conference_sponsors_path(conference_id: @conference.short_title)
      end
    end

    private

    def sponsor_params
      params[:sponsor]
    end
  end
end
