class ConferenceRegistrationsController < ApplicationController
  before_filter :authenticate_user!
  load_resource :conference, find_by: :short_title
  authorize_resource :conference_registrations, class: Registration
  before_action :set_registration, only: [:edit, :update, :destroy, :show]

  def new
    @registration = current_user.registrations.build(conference_id: @conference.id)
  end

  def show
    @workshops = @registration.workshops
    @total_price = Ticket.total_price(@conference, current_user)
    @tickets = current_user.ticket_purchases.where(conference_id: 1)
  end

  def edit; end

  def create
    @registration = current_user.registrations.build(registration_params)
    @registration.conference_id = @conference.id

    if @registration.save
      # Trigger ahoy event
      ahoy.track 'Registered', title: 'New registration'

      if @conference.tickets.any? && !current_user.supports?(@conference)
        redirect_to conference_tickets_path(@conference.short_title),
                    notice: 'You are now registered and will be receiving E-Mail notifications.'
      else
        redirect_to  conference_conference_registrations_path(@conference.short_title),
                     notice: 'You are now registered and will be receiving E-Mail notifications.'
      end
    else
      flash[:alert] = "A error prohibited the registration for #{@conference.title}: "\
                        "#{@registration.errors.full_messages.join('. ')}."
      render :new
    end
  end

  def update
    if @registration.update_attributes(registration_params)
      redirect_to  conference_conference_registrations_path(@conference.short_title),
                   notice: 'Registration was successfully updated.'
    else
      flash[:alert] = "A error prohibited the registration for #{@conference.title}: "\
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
                  alert: "A error prohibited deleting the registration for #{@conference.title}: "\
                  "#{@registration.errors.full_messages.join('. ')}."
    end
  end

  protected

  def set_registration
    @registration = current_user.registrations.find_by(conference_id: @conference.id)
    if !@registration
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
              :id, :name, :tshirt, :mobile, :volunteer_experience, :languages]
    )
  end
end
