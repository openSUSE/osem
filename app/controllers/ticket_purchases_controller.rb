class TicketPurchasesController < ApplicationController
  before_filter :authenticate_user!
  load_resource :conference, find_by: :short_title
  authorize_resource :conference_registrations, class: Registration

  def create
    message = TicketPurchase.purchase(@conference, current_user, params[:tickets][0])
    if message.blank?
      if current_user.ticket_purchases.any?
        redirect_to conference_conference_registrations_path(@conference.short_title),
                    notice: "Thank you for supporting #{@conference.title} by purchasing a ticket."
      else
        redirect_to conference_conference_registrations_path(@conference.short_title)
      end
    else
      redirect_to conference_conference_registrations_path(@conference.short_title),
                  alert: "Oops, something went wrong with your purchase! #{message}"
    end
  end

  def destroy
    @ticket_purchases = current_user.ticket_purchases.find(params[:id])
    if @ticket_purchases.destroy
      redirect_to conference_conference_registrations_path(@conference.short_title),
                  notice: 'Ticket successfully deleted.'
    else
      redirect_to conference_conference_registrations_path(@conference.short_title),
                  alert: 'An error prohibited deleting your purchase! '\
                        "#{@ticket_purchases.errors.full_messages.join('. ')}."
    end
  end
end
