class PhysicalTicketController < ApplicationController
  before_action :authenticate_user!
  load_resource :conference, find_by: :short_title
  load_and_authorize_resource
  authorize_resource :conference_registrations, class: Registration

  def index
    @physical_tickets = current_user.physical_tickets.by_conference(@conference)
  end

  def show
    @file_name = "ticket_for_#{@conference.short_title}"
    @user = @physical_ticket.user
  end
end
