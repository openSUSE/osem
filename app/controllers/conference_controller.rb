class ConferenceController < ApplicationController
  before_filter :respond_to_options
  load_and_authorize_resource find_by: :short_title

  def index
    @current = Conference.where('end_date >= ?', Date.current).order('start_date ASC')
    @antiquated = @conferences - @current
  end

  def show
    @keynote_speakers = @conference.keynote_speakers
  end

  def gallery_photos
    @photos = @conference.photos
    render 'photos', formats: [:js]
  end

  private

    def respond_to_options
      respond_to do |format|
        format.html { head :ok }
      end if request.options?
    end
end
