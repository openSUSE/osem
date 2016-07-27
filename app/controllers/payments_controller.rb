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
    @unpaid_ticket_purchases = current_user.ticket_purchases.unpaid.by_conference(@conference)
  end

  def create
    @unpaid_ticket_purchases = current_user.ticket_purchases.unpaid.by_conference(@conference)
    @total_amount_to_pay = Ticket.total_price(@conference, current_user, paid: false)

    customer = Stripe::Customer.create(
      :email => params[:stripeEmail],
      :source  => params[:stripeToken]
    )

    gateway_response = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => @total_amount_to_pay.cents,
      :description => 'Rails Stripe customer',
      :currency    => @conference.tickets.first.price_currency
    )

    payment = Payment.purchase(gateway_response, current_user, @conference)
    update_purchased_ticket_purchases(payment)

    redirect_to conference_conference_registration_path(@conference.short_title),
      flash: { success: 'Thanks! You have purchased your tickets successfully.' }

    rescue Stripe::CardError => e
      flash[:error] = e.message
      render 'new'
  end

private

  def update_purchased_ticket_purchases(payment)
    current_user.ticket_purchases.by_conference(@conference).unpaid.update_all(paid: true, payment_id: payment.id)
  end
end
