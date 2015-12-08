class TicketsController < ApplicationController
  before_filter :authenticate_user!
  load_resource :conference, find_by: :short_title
  load_resource :ticket, through: :conference
  authorize_resource :conference_registrations, class: Registration
  before_filter :check_load_resource, only: :index

  def index; end

  def check_load_resource
    if @tickets.empty?
      flash[:notice] = "There are no tickets available for #{@conference.title}!"
      redirect_to root_path
    end
  end
end
