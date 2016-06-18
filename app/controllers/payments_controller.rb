class PaymentsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  load_resource :conference, find_by: :short_title
  authorize_resource :conference_registrations, class: Registration

  def index
    @payments = Payment.where(user_id: current_user.id)
  end

  def new
    @total_amount_to_pay = Ticket.total_price(@conference, current_user, 'f')
  end

  def create
    @payment = Payment.new(payment_params)
    @total_amount_to_pay = Ticket.total_price(@conference, current_user, 'f')

    if @payment.valid?
      if @payment.purchase(current_user, @conference)
        @payment.save
        @update_ticket_purchases = TicketPurchase.update_paid_ticket_purchases(@conference, current_user, @payment)
        return redirect_to conference_conference_registrations_path(@conference.short_title), flash: { success: 'Thanks! You have purchased your tickets successfully.' }
      end
    end
    render 'new'
  end

  private

  def payment_params
    params.require(:payment).permit(:first_name, :last_name, :credit_card_number, :expiration_month, :expiration_year, :card_verification_value, :amount)
  end
end
