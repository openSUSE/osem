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
        flash[:notice] = 'Room successfully created.'
        redirect_to(admin_conference_venue_rooms_path(conference_id: @conference.short_title))
      else
        flash[:error] = "Creating Room failed: #{@room.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      if @room.update_attributes(room_params)
        flash[:notice] = 'Room successfully updated.'
        redirect_to(admin_conference_venue_rooms_path(conference_id: @conference.short_title))
      else
        flash[:error] = "Update Room failed: #{@room.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @room.destroy
        flash[:notice] = 'Room successfully deleted.'
        redirect_to(admin_conference_venue_rooms_path(conference_id: @conference.short_title))
      else
        flash[:error] = "Destroying room failed! #{@room.errors.full_messages.join('. ')}."
        redirect_to(admin_conference_venue_rooms_path(conference_id: @conference.short_title))
      end
    end

    private

    def room_params
      params.require(:room).permit(:name, :size)
    end
  end
end
