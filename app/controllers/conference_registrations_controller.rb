class ConferenceRegistrationsController < ApplicationController
  before_filter :authenticate_user!, except: [:new, :create]
  load_resource :conference, find_by: :short_title
  authorize_resource :conference_registrations, class: Registration
  before_action :set_registration, only: [:edit, :update, :destroy, :show]

  def new
    # Redirect to registration edit when user is already registered
    if @conference.user_registered?(current_user)
      redirect_to edit_conference_conference_registrations_path(@conference.short_title)
      return
    # ichain does not allow us to create users during registration
    elsif CONFIG['authentication']['ichain']['enabled'] && !current_user
      redirect_to root_path, alert: 'You need to sign in or sign up before continuing.'
      return
    end
    @registration = Registration.new
    @registration.build_user
  end

  def show
    @workshops = @registration.workshops
    @total_price = Ticket.total_price(@conference, current_user)
    @tickets = current_user.ticket_purchases.where(conference_id: @conference.id)
  end

  def edit; end

  def create
    @registration = Registration.new(registration_params)
    @registration.conference = @conference
    @registration.user = current_user if current_user

    if @registration.save
      # Trigger ahoy event
      ahoy.track 'Registered', title: 'New registration'

      # Sign in the new user
      if !current_user
        sign_in(@registration.user)
      end

      flash[:notice] = 'You are now registered and will be receiving E-Mail notifications.'
      if @conference.tickets.any? && !current_user.supports?(@conference)
        redirect_to conference_tickets_path(@conference.short_title)
      else
        redirect_to  conference_conference_registrations_path(@conference.short_title)
      end
    else
      flash[:error] = "An error prohibited the registration for #{@conference.title}: "\
                        "#{@registration.errors.full_messages.join('. ')}."
      render :new
    end
  end

  def update
    if @registration.update_attributes(registration_params)
      redirect_to  conference_conference_registrations_path(@conference.short_title),
                   notice: 'Registration was successfully updated.'
    else
      flash[:error] = "An error prohibited the registration for #{@conference.title}: "\
                        "#{@registration.errors.full_messages.join('. ')}."
      render :edit
    end
  end

  def destroy
    if @registration.destroy
      redirect_to root_path,
                  notice: "You are not registered for #{@conference.title} anymore!"
    else
      redirect_to root_path,
                  error: "An error prohibited deleting the registration for #{@conference.title}: "\
                  "#{@registration.errors.full_messages.join('. ')}."
    end
  end

  protected

  def set_registration
    @registration = Registration.find_by(conference: @conference, user: current_user)
    if !@registration
      flash[:alert] = "Can't find a registration for #{@conference.title} for you. Please register."
      redirect_to new_conference_conference_registrations_path(@conference.short_title)
    end
  end

  def registration_params
    params.require(:registration).
        permit(
          :conference_id, :arrival, :departure,
          :volunteer,
          vchoice_ids: [], qanswer_ids: [],
          qanswers_attributes: [],
          event_ids: [],
          user_attributes: [
            :username, :email, :name, :password, :password_confirmation]
    )
  end
end
