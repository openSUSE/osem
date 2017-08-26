module Admin
  class SponsorsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :sponsor, through: :conference
    before_action :sponsorship_level_required, only: [:index, :new]

    helper_method :add_swags

    def index
      authorize! :index, Sponsor.new(conference_id: @conference.id)
    end

    def show
      @sponsor.swag_index = @sponsor.swags.length
    end

    def edit
      @sponsor.swag_index = @sponsor.swags.length
      @sponsor.swags = @sponsor.swags
    end

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
        redirect_to admin_conference_sponsor_path(
                    conference_id: @conference.short_title, id: @sponsor.id),
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

    def add_swags(form, index)
      render partial: 'swag_fields', locals: { f: form, index: (index + 1), v_type: nil, v_quantity: 0}
    end



    def get_swags; end

    def paid
      @sponsor.paid = !@sponsor.paid
      if @sponsor.save
        flash[:notice] = 'Sponsor successfully updated.'
      else
        flash[:error] = 'Sponsor failed to be updated.'
      end
    end

    def has_swag
      @sponsor.has_swag = !@sponsor.has_swag
      if @sponsor.save
        flash[:notice] = 'Sponsor successfully updated.'
      else
        flash[:error] = 'Sponsor failed to be updated.'
      end
    end

    def swag_received
      @sponsor.swag_received = !@sponsor.swag_received
      if @sponsor.save
        flash[:notice] = 'Sponsor successfully updated.'
      else
        flash[:error] = 'Sponsor failed to be updated.'
      end
    end

    private

    def sponsor_params
      params.require(:sponsor).permit(:name, :description, :website_url, :picture, :picture_cache, :sponsorship_level_id, :conference_id,
                                      :paid, :has_swag, :swag_received, :address, :vat, :has_banner, :swag_index, swags: [:type, :quantity])
    end

    def sponsorship_level_required
      return unless @conference.sponsorship_levels.empty?
      redirect_to admin_conference_sponsorship_levels_path(conference_id: @conference.short_title),
                  alert: 'You need to create atleast one sponsorship level to add a sponsor'
    end
  end
end
