class ConferenceController < ApplicationController
  def show
    @conference = Conference.find_by_short_title(params[:id])
  end
end
