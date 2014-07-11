class ConferenceController < ApplicationController
  load_and_authorize_resource find_by: :short_title

  def show
    not_found unless @conference.make_conference_public?
  end

  def gallery_photos
    @photos = @conference.photos
    render "photos", formats: [:js]
  end
end
