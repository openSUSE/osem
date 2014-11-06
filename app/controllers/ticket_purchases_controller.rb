class TicketPurchasesController < ApplicationController
  before_filter :authenticate_user!
  load_resource :conference, find_by: :short_title
  authorize_resource :conference_registrations, class: Registration

  def create
    message = TicketPurchase.purchase(@conference, current_user, params[:tickets][0])
    if message.blank?
      redirect_to conference_conference_registrations_path(@conference.short_title),
                  notice: 'Congratulations, you have successfully purchased a ticket! ' \
                    "You can pay for it in cash when you arrive! Thank you for supporting #{@conference.title}!"
    else
      redirect_to conference_conference_registrations_path(@conference.short_title),
                  alert: "Oops, something went wrong with your purchase! #{message}"
    end
  end

  def destroy
    @ticket_purchases = current_user.ticket_purchases.find_by(ticket_id: params[:id])
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
