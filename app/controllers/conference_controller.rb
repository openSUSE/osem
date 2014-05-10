class ConferenceController < ApplicationController
  layout false

  def show
  	@conference = Conference.find_by_title(params[:id])
  end
end
