class ConferenceRegistrationsController < ApplicationController
  before_filter :authenticate_user!, except: [:new, :create]
  load_resource :conference, find_by: :short_title
  authorize_resource :conference_registrations, class: Registration, except: [:new, :create]
  before_action :set_registration, only: [:edit, :update, :destroy, :show]

  def new
    @registration = Registration.new(conference_id: @conference.id)
    authorize! :new, @registration, message: "Sorry, you can not register for #{@conference.title}. Registration limit exceeded or the registration is not open."

    # Redirect to registration edit when user is already registered
    if @conference.user_registered?(current_user)
      redirect_to edit_conference_conference_registration_path(@conference.short_title)
      return
    # ichain does not allow us to create users during registration
    elsif (ENV['OSEM_ICHAIN_ENABLED'] == 'true') && !current_user
      redirect_to root_path, alert: 'You need to sign in or sign up before continuing.'
      return
    end

    # avoid openid sign_in to redirect to register/new when the sign_in user had already a registration
    if current_user && @conference.user_registered?(current_user)
      redirect_to edit_conference_conference_registration_path(@conference.short_title)
    end

    # @user variable needs to be set so that _sign_up_form_embedded works properly
    @user = @registration.build_user
  end

  def show
    @total_price = Ticket.total_price(@conference, current_user)
    @tickets = current_user.ticket_purchases.where(conference_id: @conference.id)
  end

  def edit; end

  def create
    @registration = @conference.registrations.new(registration_params)

    if current_user.nil?
      # @user variable needs to be set so that _sign_up_form_embedded works properly
      @user = @registration.build_user(user_params)
    else
      @user = current_user
    end

    @registration.user = @user
    authorize! :create, @registration

    if @registration.save
      # Trigger ahoy event
      ahoy.track 'Registered', title: 'New registration'

      # Sign in the new user
      if !current_user
        sign_in(@registration.user)
      end

      if @conference.tickets.any? && !current_user.supports?(@conference)
        redirect_to conference_tickets_path(@conference.short_title),
                    notice: 'You are now registered and will be receiving E-Mail notifications.'
      else
        redirect_to conference_conference_registration_path(@conference.short_title),
                    notice: 'You are now registered and will be receiving E-Mail notifications.'
      end
    else
      flash[:error] = "Could not create your registration for #{@conference.title}: "\
                        "#{@registration.errors.full_messages.join('. ')}."
      render :new
    end
  end

  def update
    if @registration.update_attributes(registration_params)
      redirect_to  conference_conference_registration_path(@conference.short_title),
                   notice: 'Registration was successfully updated.'
    else
      flash[:error] = "Could not update your registration for #{@conference.title}: "\
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
    if !@registration
      redirect_to new_conference_conference_registration_path(@conference.short_title),
                  error: "Can't find a registration for #{@conference.title} for you. Please register."
    end
  end

  def user_params
    params.require(:user).permit(:username, :email, :name, :password, :password_confirmation)
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
