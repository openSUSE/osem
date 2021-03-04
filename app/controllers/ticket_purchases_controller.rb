# frozen_string_literal: true

class TicketPurchasesController < ApplicationController
  before_action :authenticate_user!
  load_resource :conference, find_by: :short_title
  authorize_resource :conference_registrations, class: Registration
  authorize_resource

  def create
    current_user.ticket_purchases.by_conference(@conference).unpaid.destroy_all

    # Create a ticket purchase which can be paid or unpaid
    message = TicketPurchase.purchase(@conference, current_user, params[:tickets].try(:first))
    current_ticket_purchase = ?

    # Failed to create ticket purchase
    if !message.blank?
      redirect_to conference_tickets_path(@conference.short_title),
                  error: "Oops, something went wrong with your purchase! #{message}"
      return
    end

    # Ticket purchase created but not paid
    if current_user.ticket_purchases.by_conference(@conference).unpaid.any?
      redirect_to new_conference_payment_path,
                  notice: 'Please pay here to get tickets.'
      return
    end

    # TODO: User already paid for a registration ticket and ticket purchase contains one
    # BUG: When the ticket is free, user will see the notice after they click `Continue`

    # this works? maybe 

    # TODO: Need to check 

    # user has a registration ticket
    # current_user.tickets.for_registration(@conference).present?

    # current ticket purchase 
    if current_user.ticket_purchases.by_conference(@conference).paid.any?
      && current_user.has_registration_ticket_for?(@conference) == true
    end
      for ticket_purchase in current_user.ticket_purchases.by_conference(@conference)
        if ticket_purchase.paid?
          for physical_ticket in ticket_purchase.physical_tickets
            if physical_ticket.ticket.registration_ticket?
              redirect_to conference_physical_tickets_path,
                    notice: 'You already have tickets for the conference.'
              return
          end
        end
      end
    end

    # TODO: User wants to purchase a non-registration ticket but does not have a registration ticket but conference requires one
    # BUG: When the user only purchases a non-registration ticket, 
    if @conference.registration_ticket_required? 
      && current_user.has_registration_ticket_for?(@conference) == false
        redirect_to conference_tickets_path(@conference.short_title),
                    error: 'Please get at least one registration ticket to continue.'
        return
      end
    end

    # TODO: Need to check if the current user didn't have a registration ticket and is purchasing one
    if current_user.tickets.for_registration(@conference).nil?
      if current_user.has_registration_ticket_for?(@conference) == true
        redirect_to new_conference_conference_registration_path(@conference.short_title)
      else
        redirect_to conference_physical_tickets_path
      end
    else 
      redirect_to conference_physical_tickets_path
    end
  end

  def index
    @unpaid_ticket_purchases = current_user.ticket_purchases.by_conference(@conference).unpaid
  end

  private

  def ticket_purchase_params
    params.require(:ticket_purchase).permit(:ticket_id, :user_id, :conference_id, :quantity)
  end
end
