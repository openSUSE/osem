class EventsRegistrationsController < ApplicationController
  load_resource :conference, find_by: :short_title
  load_resource :program, through: :conference, singleton: true
  load_resource :proposal, class: 'Event'
  load_resource :registration, through: :conference
  before_action :load_events_registration
  authorize_resource only: [:index, :toggle_attendance]
  after_action :prepare_unobtrusive_flash, only: [:toggle, :toggle_attendance]

  def index
    @registration = @conference.registrations.find_by(conference: @conference, user: current_user)

    @events = @registration ? @registration.events_ordered : @program.events.require_registration
  end

  def show
    authorize! :update, @proposal
  end

  def toggle_attendance
    @events_registration = EventsRegistration.find_by(event_id: @proposal.id, registration_id: @registration.id)
    @events_registration.attended = !@events_registration.attended

    if @events_registration.attended
      if @events_registration.save
        flash[:notice] = "You have marked #{@registration.email} as attended."
      else
        flash[:error] = "Failed to mark #{@registration.email} as attended."
      end
    elsif @events_registration.save
      flash[:notice] = "You have marked #{@registration.email} as NOT attended."
    else
      flash[:error] = "Failed to mark #{@registration.email} as NOT attended."
    end

    respond_to do |format|
      format.js
    end
  end

  def toggle
    authorize! :toggle, @events_registration

    if params[:state] == 'false'
      # Destroy the registration to the event
      if @events_registration.destroy
        flash[:notice] = "You successfully unregistered from '#{@proposal.title}'"
      else
        flash[:error] = "Failed to unregister you from '#{@proposal.title}'. Please try again."
      end
    elsif params[:state] == 'true'
      # Create the registration to the event
      if @events_registration.save
        flash[:notice] = "You successfully registered to '#{@proposal.title}'"

        if params[:send_email] == 'true'
          if @events_registration.send_email_on_new_event_registration?
            @events_registration.send_event_registration_mail
          end
        end
      else
        flash[:error] = "Failed to register you to '#{@proposal.title}'. Please try again."
      end
    else
      flash[:error] = 'Something went wrong. Please take action again.'
    end

    respond_to do |format|
      format.js
    end
  end

  private

  def events_registrations_params
    params.require(:events_registrations).permit(:event_id, :registration_id)
  end

  def load_events_registration
    @events_registration = EventsRegistration.find_or_initialize_by(event: @proposal, registration: @registration)
  end
end
