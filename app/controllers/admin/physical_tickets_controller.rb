# frozen_string_literal: true

module Admin
  class PhysicalTicketsController < Admin::BaseController
    before_action :authenticate_user!
    load_resource :conference, find_by: :short_title
    load_and_authorize_resource
    authorize_resource :conference_registrations, class: Registration

    def index
      @physical_tickets = @conference.physical_tickets
      @tickets_sold_distribution = @conference.tickets_sold_distribution
      @tickets_turnover_distribution = @conference.tickets_turnover_distribution
    end
  end
end
