class PaymentsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  load_resource :conference, find_by: :short_title
  authorize_resource :conference_registrations, class: Registration

  def index
    @payments = current_user.payments
  end

  def new
    @total_amount_to_pay = Ticket.total_price(@conference, current_user, 'f')
  end

  def create
    @payment = Payment.new(payment_params)
    @total_amount_to_pay = Ticket.total_price(@conference, current_user, 'f')

    if @payment.valid? && @payment.purchase(current_user, @conference, price_in_cents)
      @payment.save
      @update_ticket_purchases = TicketPurchase.update_paid_ticket_purchases(@conference, current_user, @payment)
    end

    if @payment.save
      redirect_to conference_conference_registrations_path(@conference.short_title), flash: { success: 'Thanks! You have purchased your tickets successfully.' }
    else
      render 'new'
    end
  end

  private

  def price_in_cents
    (@payment.amount * 100).round
  end

  def payment_params
    params.require(:payment).permit(:first_name, :last_name, :credit_card_number, :expiration_month, :expiration_year, :card_verification_value, :amount)
  end
end
