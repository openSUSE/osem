# frozen_string_literal: true

module Admin
  class TicketScanningsController < Admin::BaseController
    before_action :authenticate_user!
    load_resource :physical_ticket, find_by: :token
    # We authorize manually in these actions
    skip_authorize_resource only: [:create]

    def create
      @ticket_scanning = TicketScanning.new(physical_ticket: @physical_ticket)
      authorize! :create, @ticket_scanning
      @ticket_scanning.save
      redirect_to conferences_path,
                  notice: "Ticket with token #{@physical_ticket.token} successfully scanned."
    end
  end
end
