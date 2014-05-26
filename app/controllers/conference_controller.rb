class ConferenceController < ApplicationController
  def show
    @conference = Conference.find_by_short_title(params[:id])
    @keynote_speakers = @conference.registrations.joins(:person).where('featured=?', true)
  end
end
