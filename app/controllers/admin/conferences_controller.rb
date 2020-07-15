# frozen_string_literal: true

module Admin
  class ConferencesController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_resource :program, through: :conference, singleton: true, except: :index
    load_resource :user, only: [:remove_user]

    def index
      # Redirect to new form if there is no conference
      if Conference.count == 0
        redirect_to new_admin_conference_path
        return
      end

      @total_user = User.count
      @new_user = User.where('created_at > ?', current_user.last_sign_in_at).count

      @total_reg = Registration.count
      @new_reg = Registration.where('created_at > ?', current_user.last_sign_in_at).count

      @total_submissions = Event.count
      @new_submissions = Event.where('created_at > ?', current_user.last_sign_in_at).count

      @total_withdrawn = Event.where(state: :withdrawn).count
      @new_withdrawn = Event
          .where('state = ? and created_at > ?', 'withdrawn', current_user.last_sign_in_at).count

      @active_conferences = Conference.get_active_conferences_for_dashboard # pending or the last two
      @deactive_conferences = Conference
          .get_conferences_without_active_for_dashboard(@active_conferences) # conferences without active
      @conferences = @active_conferences + @deactive_conferences

      @recent_users = User.limit(5).order(created_at: :desc)
      @recent_events = Event.limit(5).order(created_at: :desc)
      @recent_registrations = Registration.limit(5).order(created_at: :desc)

      @top_submitter = Conference.get_top_submitter

      @registrations = []
      @submissions = []
      @tickets = []

      @conferences.each do |c|
        # Conference registrations over time chart
        @registrations << {
          name: c.short_title,
          data: c.get_registrations_per_week
        }
        # Event submissions over time chart
        @submissions << {
          name: c.short_title,
          data: c.get_submissions_per_week
        }
        # Tickets sold over time chart
        @tickets << {
          name: c.short_title,
          data: c.get_tickets_sold_per_week
        }
      end

      @event_distribution = Conference.event_distribution
      @event_distribution_colors = Event::COLORS.values

      @user_distribution = User.distribution
      @user_distribution_colors = User::DISTRIBUTION_COLORS.values
    end

    def new
      @conference = Conference.new
      @organizations = Organization.accessible_by(current_ability, :update).pluck(:name, :id)
    end

    def create
      @conference = Conference.new(conference_params)

      if @conference.save
        # user that creates the conference becomes organizer of that conference
        current_user.add_role :organizer, @conference

        redirect_to admin_conference_path(id: @conference.short_title),
                    notice: 'Conference was successfully created.'
      else
        flash.now[:error] = 'Could not create conference. ' + @conference.errors.full_messages.to_sentence
        render action: 'new'
      end
    end

    def update
      short_title = @conference.short_title
      @conference.assign_attributes(conference_params)
      send_mail_on_conf_update = @conference.notify_on_dates_changed?

      if @conference.update_attributes(conference_params)
        ConferenceDateUpdateMailJob.perform_later(@conference) if send_mail_on_conf_update
        redirect_to edit_admin_conference_path(id: @conference.short_title),
                    notice: 'Conference was successfully updated.'
      else
        redirect_to edit_admin_conference_path(id: short_title),
                    error: 'Updating conference failed. ' \
                    "#{@conference.errors.full_messages.join('. ')}."
      end
    end

    def show
      @program = @conference.program || Program.new(conference_id: @conference.id)

      # Overview and since last login information
      @total_reg = @conference.registrations.count
      @new_reg = @conference.registrations.where('created_at > ?', current_user.last_sign_in_at).count

      @all_events = @program.events

      @total_submissions = @all_events.count
      # @new_submissions = @all_events
      #     .where('created_at > ?', current_user.last_sign_in_at).count

      @program_length = @conference.current_program_hours
      # @new_program_length = @conference.new_program_hours(current_user.last_sign_in_at)

      @total_withdrawn = @all_events.where(state: :withdrawn).count
      # @new_withdrawn = @all_events.where(state: :withdrawn).where(
      #   'events.created_at > ?',
      #   current_user.last_sign_in_at
      # ).count

      #  Step by step list
      # @conference_progress = @conference.get_status

      # Line charts
      @registrations = @conference.get_registrations_per_week
      @submissions = @conference.get_submissions_data
      @tickets = @conference.get_tickets_data

      # Doughnut charts
      @event_type_distribution = @conference.event_type_distribution
      # @event_type_distribution_confirmed = @conference.event_type_distribution(:confirmed)
      # @event_type_distribution_withdrawn = @conference.event_type_distribution(:withdrawn)

      @difficulty_levels_distribution = @conference.difficulty_levels_distribution
      # @difficulty_levels_distribution_confirmed = @conference
      #     .difficulty_levels_distribution(:confirmed)
      # @difficulty_levels_distribution_withdrawn = @conference
      #     .difficulty_levels_distribution(:withdrawn)

      @tracks_distribution = @conference.tracks_distribution
      # @tracks_distribution_confirmed = @conference.tracks_distribution(:confirmed)
      # @tracks_distribution_withdrawn = @conference.tracks_distribution(:withdrawn)

      # Recent actions information
      @recent_events = @conference.program.events.limit(5).order(created_at: :desc)
      @recent_registrations = @conference.registrations.limit(5).order(created_at: :desc)

      @top_submitter = @conference.get_top_submitter

      respond_to do |format|
        format.html
        format.json { render json: @conference.to_json }
      end
    end

    def edit
      @conferences = Conference.all
      @date_string = date_string(@conference.start_date, @conference.end_date)
      @affected_event_count = @conference.program.events.scheduled(@conference.program.selected_schedule_id).count
      respond_to do |format|
        format.html
        format.json { render json: @conference.to_json }
      end
    end

    private

    def conference_params
      params.require(:conference).permit(:title, :short_title, :description, :timezone,
                                         :start_date, :end_date, :start_hour, :end_hour,
                                         :rooms_attributes, :tracks_attributes,
                                         :tickets_attributes, :event_types_attributes,
                                         :picture, :picture_cache, :questions_attributes,
                                         :question_ids, :answers_attributes, :answer_ids, :difficulty_levels_attributes,
                                         :use_vpositions, :use_vdays, :vdays_attributes,
                                         :vpositions_attributes, :use_volunteers, :color,
                                         :sponsorship_levels_attributes, :sponsors_attributes,
                                         :registration_limit, :organization_id, :ticket_layout,
                                         :booth_limit, :custom_css)
    end
  end
end
