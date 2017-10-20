module Admin
  class SponsorsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :sponsor, through: :conference
    before_action :sponsorship_level_required, only: [:index, :new]

    def index
      authorize! :index, Sponsor.new(conference_id: @conference.id)
    end

    def show; end

    def edit
      @sponsor.swag_index = @sponsor.swag.length
      @sponsor.carrier_index = @sponsor.swag_transportation.length
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
        @sponsor.update_attribute(:swag, @sponsor.swag.reject! { |_key, value| value[:type].blank? || value[:quantity].blank? })
        @sponsor.update_attribute(:swag_transportation, @sponsor.swag_transportation.reject! { |_key, value| value[:carrier_name].blank? || value[:tracking_number].blank? })

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

    def confirm
      @sponsor.confirm!

      if @sponsor.save
        redirect_to admin_conference_sponsors_path(@conference.short_title),
                    notice: 'Sponsor successfully confirmed!'
      else
        flash[:error] = 'Sponsor couldn\' t be confirmed.'
      end
    end

    def cancel
      @sponsor.cancel!

      if @sponsor.save
        redirect_to admin_conference_sponsors_path(@conference.short_title),
                    notice: 'Sponsor successfully canceled'
      else
        flash[:error] = 'Sponsor couldn\'t be canceled'
      end
    end

    def contact
      @sponsor.contact!

      if @sponsor.save
        redirect_to admin_conference_sponsors_path(@conference.short_title),
                    notice: 'Sponsor\'s state successfully updated'
      else
        flash[:error] = 'Sponsor\'s state  couldn\'t be updated'
      end
    end

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
                                      :paid, :has_swag, :swag_received, :address, :vat, :has_banner, :swag_index, :carrier_index, :amount,
                                      responsibe: [:responsible_name, :responsible_email], swag: [:type, :quantity],
                                      swag_transportation: [:carrier_name, :tracking_number, :boxes])
    end

    def sponsorship_level_required
      return unless @conference.sponsorship_levels.empty?
      redirect_to admin_conference_sponsorship_levels_path(conference_id: @conference.short_title),
                  alert: 'You need to create atleast one sponsorship level to add a sponsor'
    end
  end
end
