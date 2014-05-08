class ConferenceController < ApplicationController
  def show
  	@conference = Conference.find_by_title(params[:conference_id])
  end
end
