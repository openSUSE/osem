class HomeController < ApplicationController
  before_filter :respond_to_options
  skip_authorization_check

  def index
    @today = Date.current
    @current = Conference.where("end_date >= ?", @today).order("start_date ASC")
  end

  def respond_to_options
    respond_to do |format|
      format.html { head :ok }
    end if request.options?
  end
end
