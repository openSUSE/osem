class HomeController < ApplicationController
  def index
    @today = Date.current
    @conferences = Conference.where("start_date >= ?", @today)
  end
end
