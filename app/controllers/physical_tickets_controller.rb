# frozen_string_literal: true

class PhysicalTicketsController < ApplicationController
  before_action :authenticate_user!
  load_resource :conference, find_by: :short_title
  load_and_authorize_resource find_by: :token
  authorize_resource :conference_registrations, class: Registration

  def index
    @physical_tickets = current_user.physical_tickets.by_conference(@conference)
    @has_registration_ticket = current_user.ticket_purchases.where(ticket: @conference.registration_tickets, paid: true).any?
    @unpaid_ticket_purchases = current_user.ticket_purchases.by_conference(@conference).unpaid
    @user = current_user
  end

  def show
    @file_name = "ticket_for_#{@conference.short_title}.pdf"
    @user = @physical_ticket.user
    @ticket_layout = @conference.ticket_layout.to_sym
    @qrcode_image = RQRCode::QRCode.new(@physical_ticket.token).as_png(size: 180, border_modules: 0)
    respond_to do |format|
      format.html
      format.pdf do
        pdf = TicketPdf.new(@conference, @user, @physical_ticket, @ticket_layout, @file_name)
        send_data pdf.render,
                  filename:    @file_name,
                  type:        'application/pdf',
                  disposition: 'attachment'
      end
    end
  end
end
