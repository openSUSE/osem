class HomeController < ApplicationController
  def index
    @today = Date.current
    @current = Conference.where("start_date >= ?", @today)
  end
end
