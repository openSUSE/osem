# frozen_string_literal: true

class ConferenceRegistrationsController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create]
  load_resource :conference, find_by: :short_title
  authorize_resource :conference_registrations, class: Registration, except: [:new, :create]
  before_action :set_registration, only: [:edit, :update, :destroy, :show]

  def new
    @registration = Registration.new(conference_id: @conference.id)

    # Redirect to registration edit when user is already registered
    if @conference.user_registered?(current_user)
      # Authorization needs to happen in every action before the return statement
      # We authorize the #edit action, since we redirect to it
      authorize! :edit, current_user.registrations.find_by(conference_id: @conference.id)
      redirect_to edit_conference_conference_registration_path(@conference.short_title)
      return
    end

    if !@conference.registration_open? || @conference.registration_limit_exceeded?
      message = "Sorry, you can not register for #{@conference.title}. Registration limit exceeded or the registration is not open."
      @ignore_not_signed_in_user = true
    end
    authorize! :new, @registration, message: message

    # @user variable needs to be set so that _sign_up_form_embedded works properly
    @user = @registration.build_user
  end

  def show
    @total_price = Ticket.total_price_user(@conference, current_user, paid: true)
    @tickets = current_user.ticket_purchases.by_conference(@conference).paid
    @total_price_per_ticket = @tickets.group(:ticket_id).sum('amount_paid * quantity')
    @ticket_payments = @tickets.group_by(&:ticket_id)
    @total_quantity = @tickets.group(:ticket_id).sum(:quantity)
  end

  def edit; end

  def create
    @registration = @conference.registrations.new(registration_params)

    @user = if current_user.nil?
              # @user variable needs to be set so that _sign_up_form_embedded works properly
              @registration.build_user(user_params)
            else
              current_user
            end

    @registration.user = @user
    authorize! :create, @registration

    if @registration.save
      # Sign in the new user
      unless current_user
        sign_in(@registration.user)
      end

      if @conference.tickets.visible.any? && !current_user.supports?(@conference)
        redirect_to conference_tickets_path(@conference.short_title),
                    notice: 'You are now registered and will be receiving E-Mail notifications.'
      else
        redirect_to conference_conference_registration_path(@conference.short_title),
                    notice: 'You are now registered and will be receiving E-Mail notifications.'
      end
    else
      flash.now[:error] = "Could not create your registration for #{@conference.title}: "\
                        "#{@registration.errors.full_messages.join('. ')}."
      render :new
    end
  end

  def update
    if @registration.update_attributes(registration_params)
      redirect_to  conference_conference_registration_path(@conference.short_title),
                   notice: 'Registration was successfully updated.'
    else
      flash.now[:error] = "Could not update your registration for #{@conference.title}: "\
                        "#{@registration.errors.full_messages.join('. ')}."
      render :edit
    end
  end

  def destroy
    if @registration.destroy
      redirect_to root_path,
                  notice: "You are not registered for #{@conference.title} anymore!"
    else
      redirect_to conference_conference_registration_path(@conference.short_title),
                  error: "Could not delete your registration for #{@conference.title}: "\
                  "#{@registration.errors.full_messages.join('. ')}."
    end
  end

  protected

  def set_registration
    @registration = Registration.find_by(conference: @conference, user: current_user)
    unless @registration
      redirect_to new_conference_conference_registration_path(@conference.short_title),
                  error: "Can't find a registration for #{@conference.title} for you. Please register."
    end
  end

  def user_params
    params.require(:user).permit(:username, :email, :name, :password, :password_confirmation)
  end

  def registration_params
    params.require(:registration)
        .permit(
          :conference_id,
          :volunteer, :accepted_code_of_conduct,
          vchoice_ids: [], qanswer_ids: [],
          qanswers_attributes: [],
          event_ids: [],
          user_attributes: [
            :username, :email, :name, :password, :password_confirmation]
    )
  end
end
