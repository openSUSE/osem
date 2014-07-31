module Admin
  class LodgingsController < ApplicationController
    before_filter :verify_organizer
    before_action :set_lodging, only: [:edit, :update, :destroy]
    before_action :set_venue, only: [:index]

    def index
    end

    def new
      @lodging = @conference.venue.lodgings.build
    end

    def edit
    end

    def create
      @lodging = @conference.venue.lodgings.build(lodging_params)

      if @lodging.save
        redirect_to admin_conference_lodgings_path(@conference.short_title), notice: 'Lodging was successfully created.'
      else
        flash[:alert] = "A error prohibited this Lodging from being saved: #{@lodging.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      if @lodging.update_attributes(lodging_params)
        redirect_to(admin_conference_lodgings_path(conference_id: @conference.short_title),
                    notice: 'Lodging was successfully updated.')
      else
         flash[:alert] = "A error prohibited this Lodging from being saved: #{@venue.errors.full_messages.join('. ')}."
         render :edit
      end
    end

    def destroy
      @lodging.destroy
      redirect_to admin_conference_lodgings_path, notice: 'Lodging was successfully destroyed.'
    end

    private

    def set_lodging
      @lodging = Lodging.find(params[:id])
    end

    def set_venue
      @venue = @conference.venue
    end

    def lodging_params
      params[:lodging]
    end
  end
end
