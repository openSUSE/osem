# frozen_string_literal: true

module Admin
  class RoomsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :venue, through: :conference, singleton: true
    load_and_authorize_resource through: :venue

    def index; end

    def edit; end

    def new
      @room = @venue.rooms.new
    end

    def create
      @room = @venue.rooms.new(room_params)
      if @room.save
        redirect_to admin_conference_venue_rooms_path(conference_id: @conference.short_title),
                    notice: 'Room successfully created.'
      else
        flash.now[:error] = "Creating Room failed: #{@room.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      if @room.update_attributes(room_params)
        redirect_to admin_conference_venue_rooms_path(conference_id: @conference.short_title),
                    notice: 'Room successfully updated.'
      else
        flash.now[:error] = "Update Room failed: #{@room.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @room.destroy
        redirect_to admin_conference_venue_rooms_path(conference_id: @conference.short_title),
                    notice: 'Room successfully deleted.'
      else
        redirect_to admin_conference_venue_rooms_path(conference_id: @conference.short_title),
                    error: "Destroying room failed! #{@room.errors.full_messages.join('. ')}."
      end
    end

    private

    def room_params
      params.require(:room).permit(:name, :size, :url, :order)
    end
  end
end
