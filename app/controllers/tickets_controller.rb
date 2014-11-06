class TicketsController < ApplicationController
  before_filter :authenticate_user!
  load_resource :conference, find_by: :short_title
  load_resource :tickets, class: Ticket
  authorize_resource :conference_registrations, class: Registration

  def index; end
end
