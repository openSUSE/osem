class PaymentsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  load_resource :conference, find_by: :short_title
  authorize_resource :conference_registrations, class: Registration

  def index
    @payments = current_user.payments
  end

  def new
    @total_amount_to_pay = Ticket.total_price(@conference, current_user, paid: false)
  end

  def create
    @payment = Payment.new(payment_params)
    @total_amount_to_pay = Ticket.total_price(@conference, current_user, paid: false)

    if @payment.purchase(current_user, @conference, price_in_cents) && @payment.save
      update_purchased_ticket_purchases
      redirect_to conference_conference_registration_path(@conference.short_title), flash: { success: 'Thanks! You have purchased your tickets successfully.' }
    else
      render 'new'
    end
  end

  private

  def price_in_cents
    (@payment.amount * 100).round
  end

  def update_purchased_ticket_purchases
    paid_ticket_purchases = current_user.ticket_purchases.by_conference(@conference).unpaid
    paid_ticket_purchases.each do |ticket|
      ticket.paid = true
      ticket.payment_id = @payment.id
      ticket.save
    end
  end

  def payment_params
    params.require(:payment).permit(:first_name, :last_name, :credit_card_number, :expiration_month, :expiration_year, :card_verification_value, :amount)
  end
end
