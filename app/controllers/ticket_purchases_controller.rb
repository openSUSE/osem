# frozen_string_literal: true

class TicketPurchasesController < ApplicationController
  before_action :authenticate_user!
  load_resource :conference, find_by: :short_title
  authorize_resource :conference_registrations, class: Registration
  authorize_resource

  def create
    current_user.ticket_purchases.by_conference(@conference).unpaid.destroy_all

    # Create a ticket purchase which can be paid or unpaid
    count_registration_tickets_before = current_user.count_registration_tickets(@conference)
    message = TicketPurchase.purchase(@conference, current_user, params[:tickets].try(:first))
    # The new ticket_purchase has been added to the database. current_user.ticket_purchases contains the new one.
    count_registration_tickets_after = current_user.count_registration_tickets(@conference)
  
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

    # Current user already paid for a registration ticket and the current ticket purchase contains one
    if count_registration_tickets_before == 1 && count_registration_tickets_after > 1
      redirect_to conference_physical_tickets_path,
            notice: 'You already have tickets for the conference.'
      return
    end

    # Conference requires a registration ticket but the current user wants to purchase a non-registration ticket 
    # and does not have a registration ticket 
    if @conference.registration_ticket_required? && count_registration_tickets_after == 0
      redirect_to conference_tickets_path(@conference.short_title),
              error: 'Please get at least one registration ticket to continue.'
      return   
    end

    # Current user didn't have a registration ticket and is purchasing one
    if count_registration_tickets_before == 0 && count_registration_tickets_after == 1
      redirect_to new_conference_conference_registration_path(@conference.short_title)
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
