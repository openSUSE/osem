class TicketPurchasesController < ApplicationController
  before_filter :authenticate_user!
  load_resource :conference, find_by: :short_title
  authorize_resource :conference_registrations, class: Registration
  authorize_resource

  def create
    current_user.ticket_purchases.by_conference(@conference).unpaid.destroy_all
    message = TicketPurchase.purchase(@conference, current_user, params[:tickets][0])
    if message.blank?
      if current_user.ticket_purchases.by_conference(@conference).unpaid.any?
        redirect_to new_conference_payment_path,
                    notice: 'Please pay here to get tickets.'
      elsif current_user.ticket_purchases.by_conference(@conference).paid.any?
        redirect_to conference_physical_ticket_index_path,
                    notice: 'You have free tickets for the conference.'
      else
        redirect_to conference_tickets_path(@conference.short_title),
                    error: 'Please get at least one ticket to continue.'
      end
    else
      redirect_to conference_tickets_path(@conference.short_title),
                  error: "Oops, something went wrong with your purchase! #{message}"
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
