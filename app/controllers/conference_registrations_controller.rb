class ConferenceRegistrationsController < ApplicationController
  before_filter :verify_user
  load_resource :conference, find_by: :short_title
  authorize_resource :conference_registrations, class: Registration
  before_action :set_registration, only: [:edit, :update, :destroy]
  before_action :set_workshops, only: [:new, :edit, :update, :create]

  def new
    @registration = current_user.registrations.build(conference_id: @conference.id)
    @registration.build_supporter_registration
  end

  def edit
  end

  def create
    user_attributes = registration_params[:user_attributes]
    params[:registration].delete :user_attributes

    @registration = current_user.registrations.build(registration_params)
    @registration.conference_id = @conference.id

    if @registration.save && current_user.update_attributes(user_attributes)
      # Trigger ahoy event
      ahoy.track 'Registered', title: 'New registration'

      # Send registration mail
      if @conference.email_settings.send_on_registration?
        Mailbot.delay.registration_mail(@conference, current_user)
      end

      # Set subscription for the conference
      Subscription.create(conference_id: @conference.id, user_id: current_user.id)

      redirect_to edit_conference_conference_registrations_path(@conference.short_title),
                  notice: 'You are now registered and will be receiving E-Mail notifications.'
    else
      flash[:alert] = "A error prohibited the registration for #{@conference.title}: "\
                        "#{@registration.errors.full_messages.join('. ')}."
      render :new
    end
  end

  def update
    if @registration.update(registration_params)
      redirect_to edit_conference_conference_registrations_path(@conference.short_title),
                  notice: 'Registration was successfully updated.'
    else
      flash[:alert] = "A error prohibited the registration for #{@conference.title}: "\
                        "#{@registration.errors.full_messages.join('. ')}."
      render :edit
    end
  end

  def destroy
    @registration.destroy
    redirect_to root_path,
                notice: "You are not registered for #{@conference.title} anymore!"
  end

  protected

  def set_workshops
    @workshops = @conference.events.where('require_registration = ? AND state LIKE ?', true, 'confirmed')
  end

  def set_registration
    @registration = current_user.registrations.where(conference_id: @conference.id).first
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
              :id, :name, :tshirt, :mobile, :volunteer_experience, :languages],
          supporter_registration_attributes: [
            :id, :supporter_level_id, :code
          ])
  end
end
