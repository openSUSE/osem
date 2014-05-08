class ConferencesController < ApplicationController
  def show
  	@conference = Conference.find_by_title(params[:format])
  end
end
