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
    @payment = Payment.new payment_params.merge(stripe_customer_email: params[:stripeEmail],
                                                stripe_customer_token: params[:stripeToken],
                                                user: current_user,
                                                conference: @conference)

    if @payment.purchase && @payment.save
      update_purchased_ticket_purchases
      redirect_to conference_conference_registration_path(@conference.short_title),
        notice: 'Thanks! You have purchased your tickets successfully.'
    else
      @total_amount_to_pay = Ticket.total_price(@conference, current_user, paid: false)
      @unpaid_ticket_purchases = current_user.ticket_purchases.unpaid.by_conference(@conference)
      render :new
    end
  end

  private

  def payment_params
    params.permit :stripe_customer_email, :stripe_customer_token
  end

  def update_purchased_ticket_purchases
    current_user.ticket_purchases.by_conference(@conference).unpaid.update_all(paid: true, payment_id: @payment.id)
  end
end
