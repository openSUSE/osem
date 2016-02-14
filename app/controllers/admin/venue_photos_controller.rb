module Admin
  class VenuePhotosController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :venue, through: :conference, singleton: true

    def destroy
      photo = @venue.venue_photos.find(params[:id])
      if photo.destroy
        redirect_to  edit_admin_conference_venue_path(@conference.short_title), notice: 'Photo deleted'
      else
        redirect_to  edit_admin_conference_venue_path(@conference.short_title), alert: 'Photo not deleted'
      end
    end
  end
end
