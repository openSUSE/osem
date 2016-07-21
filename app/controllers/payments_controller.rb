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

    if @payment.purchase && @payment.save
      update_purchased_ticket_purchases
      redirect_to conference_conference_registration_path(@conference.short_title), flash: { success: 'Thanks! You have purchased your tickets successfully.' }
    else
      @total_amount_to_pay = Ticket.total_price(@conference, current_user, paid: false)
      render 'new'
    end
  end

  private

  def update_purchased_ticket_purchases
    current_user.ticket_purchases.by_conference(@conference).unpaid.update_all(paid: true, payment_id: @payment.id)
  end

  def payment_params
    params.require(:payment)
      .permit(:full_name, :credit_card_number, :expiration_month, :expiration_year, :card_verification_value, :amount)
      .merge(user: current_user, conference: @conference)
  end
end
