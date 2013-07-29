class HomeController < ApplicationController
  def index
    @today = Date.current
    @current = Conference.where("end_date >= ?", @today).order("start_date ASC")
  end
end
