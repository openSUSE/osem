module Admin
  class EventsRegistrationsController < Admin::BaseController
    load_resource :conference, find_by: :short_title
    load_resource :program, through: :conference, singleton: true
    load_resource :event
    load_resource :registration, through: :conference
    before_action :load_events_registration
    authorize_resource only: :toggle_attendance
    after_action :prepare_unobtrusive_flash, only: [:toggle, :toggle_attendance]

    def show
      authorize! :update, @event
    end

    def toggle_attendance
      @events_registration = EventsRegistration.find_by(event_id: @event.id, registration_id: @registration.id)
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
          flash[:notice] = "You successfully unregistered #{@registration.email} from '#{@event.title}'"
        else
          flash[:error] = "Failed to unregister #{@registration.email} from '#{@event.title}'. Please try again."
        end
      elsif params[:state] == 'true'
        # Create the registration to the event
        if @events_registration.save
          flash[:notice] = "You successfully registered #{@registration.email} to '#{@event.title}'"
        else
          flash[:error] = "Failed to register #{@registration.email} to '#{@event.title}'. Please try again."
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
      @events_registration = EventsRegistration.find_or_initialize_by(event: @event, registration: @registration)
    end
  end
end
