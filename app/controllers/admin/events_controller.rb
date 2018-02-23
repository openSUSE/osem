module Admin
  class EventsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :program, through: :conference, singleton: true
    load_and_authorize_resource :event, through: :program
    load_and_authorize_resource :events_registration, only: :toggle_attendance
    # For some reason this doesn't work, so a workaround is used
    # load_and_authorize_resource :track, through: :program, only: [:index, :show, :edit]

    before_action :get_tracks, only: [:index, :show, :edit]

    # FIXME: The timezome should only be applied on output, otherwise
    # you get lost in timezone conversions...
    # around_filter :set_timezone_for_this_request

    def set_timezone_for_this_request(&block)
      Time.use_zone(@conference.timezone, &block)
    end

    def index
      @difficulty_levels = @program.difficulty_levels
      @event_types = @program.event_types
      @tracks_distribution_confirmed = @conference.tracks_distribution(:confirmed)
      @event_distribution = @conference.event_distribution
      @scheduled_event_distribution = @conference.scheduled_event_distribution
      @file_name = "events_for_#{@conference.short_title}"
      @event_export_option = params[:event_export_option]

      respond_to do |format|
        format.html
        # Explicity call #to_json to avoid the use of EventSerializer
        format.json { render json: Event.where(state: :confirmed, program: @program).to_json }
        format.xlsx do
          response.headers['Content-Disposition'] = "attachment; filename=\"#{@file_name}.xlsx\""
          render 'events'
        end
        format.pdf {render 'events'}
        format.csv do
          response.headers['Content-Disposition'] = "attachment; filename=\"#{@file_name}.csv\""
          render 'events'
        end
      end
    end

    def show
      @event_types = @program.event_types
      @comments = @event.root_comments
      @comment_count = @event.comment_threads.count
      @votes = @event.votes.includes(:user)
      @difficulty_levels = @program.difficulty_levels
      @versions = @event.versions |
       PaperTrail::Version.where(item_type: 'Commercial').where('object LIKE ?', "%commercialable_id: #{@event.id}\ncommercialable_type: Event%") |
       PaperTrail::Version.where(item_type: 'Commercial').where('object_changes LIKE ?', "%commercialable_id:\n- \n- #{@event.id}\ncommercialable_type:\n- \n- Event%") |
       PaperTrail::Version.where(item_type: 'Vote').where('object_changes LIKE ?', "%\nevent_id:\n- \n- #{@event.id}\n%") |
       PaperTrail::Version.where(item_type: 'Vote').where('object LIKE ?', "%\nevent_id: #{@event.id}\n%")
    end

    def edit
      @event_types = @program.event_types
      @comments = @event.root_comments
      @comment_count = @event.comment_threads.count
      @user = @event.submitter
      @url = admin_conference_program_event_path(@conference.short_title, @event)
      @languages = @program.languages_list
    end

    def comment
      comment = Comment.new(comment_params)
      comment.commentable = @event
      comment.user_id = current_user.id
      comment.save!
      unless params[:parent].nil?
        comment.move_to_child_of(params[:parent])
      end

      redirect_to admin_conference_program_event_path(@conference.short_title, @event)
    end

    def update
      @languages = @program.languages_list
      if @event.update_attributes(event_params)

        if request.xhr?
          render js: 'index'
        else
          flash[:notice] = "Successfully updated event with ID #{@event.id}."
          redirect_back_or_to(admin_conference_program_event_path(@conference.short_title, @event))
        end
      else
        @url = admin_conference_program_event_path(@conference.short_title, @event)
        flash.now[:error] = 'Update not successful. ' + @event.errors.full_messages.to_sentence
        render :edit
      end
    end

    def create
      @url = admin_conference_program_events_path(@conference.short_title, @event)
      @languages = @program.languages_list
      @event.submitter = current_user

      if @event.save
        ahoy.track 'Event submission', title: 'New submission'
        redirect_to admin_conference_program_events_path(@conference.short_title), notice: 'Event was successfully submitted.'
      else
        flash.now[:error] = "Could not submit proposal: #{@event.errors.full_messages.join(', ')}"
        render action: 'new'
      end
    end

    def new
      @url = admin_conference_program_events_path(@conference.short_title, @event)
      @languages = @program.languages_list
    end

    def accept
      send_mail = @event.program.conference.email_settings.send_on_accepted
      subject = @event.program.conference.email_settings.accepted_subject.blank?
      update_state(:accept, 'Event accepted!', true, subject, send_mail)
    end

    def confirm
      update_state(:confirm, 'Event confirmed!')
    end

    def cancel
      update_state(:cancel, 'Event canceled!')
      selected_schedule = @event.program.selected_schedule
      event_schedule = EventSchedule.unscoped.where(event: @event).find_by(schedule: selected_schedule) if selected_schedule
      Rails.logger.debug "schedule: #{selected_schedule.inspect} and event_schedule #{event_schedule.inspect}"
      if selected_schedule && event_schedule
        event_schedule.enabled = false
        event_schedule.save
      else
        @event.event_schedules.destroy_all
      end
    end

    def reject
      send_mail = @event.program.conference.email_settings.send_on_rejected
      subject = @event.program.conference.email_settings.rejected_subject.blank?
      update_state(:reject, 'Event rejected!', true, subject, send_mail)
    end

    def restart
      update_state(:restart, 'Review started!')
    end

    def vote
      @votes = @event.votes.includes(:user)

      if (votes = current_user.votes.find_by_event_id(params[:id]))
        votes.update_attributes(rating: params[:rating])
      else
        @myvote = @event.votes.build
        @myvote.user = current_user
        @myvote.rating = params[:rating]
        @myvote.save
      end

      respond_to do |format|
        format.html { redirect_to admin_conference_program_event_path(@conference.short_title, @event) }
        format.js
      end
    end

    def registrations
      @event_registrations = @event.events_registrations
    end

    def toggle_attendance
      @events_registration.attended = !@events_registration.attended

      if @events_registration.save
        head :ok
      else
        head :unprocessable_entity
      end
    end

    private

    def event_params
      params.require(:event).permit(
                                    # Set also in proposals controller
                                    :title, :subtitle, :event_type_id, :abstract, :description, :require_registration, :difficulty_level_id,
                                    # Set only in admin/events controller
                                    :track_id, :state, :language, :is_highlight, :max_attendees,
                                    # Not used anymore?
                                    :proposal_additional_speakers, :user, :users_attributes,
                                    speaker_ids: [])
    end

    def comment_params
      params.require(:comment).permit(:commentable, :body, :user_id)
    end

    def update_state(transition, notice, mail = false, subject = false, send_mail = false)
      alert = @event.update_state(transition, mail, subject, send_mail, params[:send_mail].blank?)

      if alert.blank?
        flash[:notice] = notice
        redirect_back_or_to(admin_conference_program_events_path(conference_id: @conference.short_title)) && return
      else
        flash[:error] = alert
        return redirect_back_or_to(admin_conference_program_events_path(conference_id: @conference.short_title)) && return
      end
    end

    def get_tracks
      @tracks = Track.accessible_by(current_ability).where(program: @program).confirmed
    end
  end
end
