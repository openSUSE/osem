module Admin
  class ConferenceController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title

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

      @active_conferences = Conference.get_active_conferences_for_dashboard # pending or the last two
      @deactive_conferences = Conference.
        get_conferences_without_active_for_dashboard(@active_conferences) # conferences without active
      @conferences = @active_conferences + @deactive_conferences

      @recent_users = User.limit(5).order(created_at: :desc)
      @recent_events = Event.limit(5).order(created_at: :desc)
      @recent_registrations = Registration.limit(5).order(created_at: :desc)

      @top_submitter = Conference.get_top_submitter

      @submissions = {}
      @cfp_weeks = [0]

      @registrations = {}
      @registration_weeks = [0]

      @conferences.each do |c|
        # Event submissions over time chart
        @submissions[c.short_title] = c.get_submissions_per_week
        @cfp_weeks.push(@submissions[c.short_title].length)

        # Conference registrations over time chart
        @registrations[c.short_title] = c.get_registrations_per_week
        @registration_weeks.push(@registrations[c.short_title].length)
      end

      @cfp_weeks = @cfp_weeks.max
      @submissions = normalize_array_length(@submissions, @cfp_weeks)
      @cfp_weeks = @cfp_weeks > 0 ? (1..@cfp_weeks).to_a : 1

      @registration_weeks = @registration_weeks.max
      @registrations = normalize_array_length(@registrations, @registration_weeks)
      @registration_weeks = @registration_weeks > 0 ? (1..@registration_weeks).to_a : 1

      @event_distribution = Conference.event_distribution
      @user_distribution = Conference.user_distribution
    end

    def new
      @conference = Conference.new
    end

    def create
      @conference = Conference.new(params[:conference])

      if @conference.valid?
        @conference.save
        # user that creates the conference becomes organizer of that conference
        current_user.add_role :organizer, @conference
        redirect_to(admin_conference_path(id: @conference.short_title),
                    notice: 'Conference was successfully created.')
      else
        render action: 'new'
      end
    end

    def update
      short_title = @conference.short_title
      @conference.assign_attributes(params[:conference])
      if @conference.start_date_changed? || @conference.end_date_changed?
        if @conference.email_settings.send_on_updated_conference_dates &&
                !@conference.email_settings.updated_conference_dates_subject.blank? &&
                @conference.email_settings.updated_conference_dates_template
          Mailbot.conference_date_update_mail(@conference).deliver
        end
      end

      if @conference.registration_start_date_changed? || @conference.registration_end_date_changed?
        if @conference.email_settings.send_on_updated_conference_registration_dates &&
        !@conference.email_settings.updated_conference_registration_dates_subject.blank? &&
        @conference.email_settings.updated_conference_registration_dates_template
          Mailbot.conference_registration_date_update_mail(@conference).deliver
        end

        if @conference.update_attributes(params[:conference])
          redirect_to(edit_admin_conference_path(id: @conference.short_title),
                      notice: 'Conference was successfully updated.')
        else
          redirect_to(edit_admin_conference_path(id: short_title),
                      alert: 'Updating conference failed. ' \
                      "#{@conference.errors.full_messages.join('. ')}.")
        end
      end
    end

    def show
      @conference = Conference.find_by(short_title: params[:id])

      # Overview and since last login information
      @total_reg = @conference.registrations.count
      @new_reg = @conference.registrations.where('created_at > ?', current_user.last_sign_in_at).count

      @total_submissions = @conference.events.count
      @new_submissions = @conference.events.
          where('created_at > ?', current_user.last_sign_in_at).count

      @program_length = @conference.current_program_hours
      @new_program_length = @conference.new_program_hours(current_user.last_sign_in_at)

      #  Step by step list
      @conference_progress = @conference.get_status

      # Line charts
      @registrations = { @conference.short_title => @conference.get_registrations_per_week }
      @registration_weeks = [0]
      @registration_weeks.push(@registrations[@conference.short_title].length)

      @registration_weeks = @registration_weeks.max
      @registrations = normalize_array_length(@registrations, @registration_weeks)
      @registration_weeks = @registration_weeks > 0 ? (1..@registration_weeks).to_a : 1

      @submissions = Conference.get_event_state_line_colors

    @submissions_data = {}
    @submissions_data = @conference.get_submissions_data
    @cfp_weeks = 0
    if @submissions_data['Weeks']
      @cfp_weeks = @submissions_data['Weeks']
      @submissions_data = @submissions_data.except('Weeks')
    end

      # Doughnut charts
      @event_type_distribution = @conference.event_type_distribution
      @event_type_distribution_confirmed = @conference.event_type_distribution(:confirmed)

      @difficulty_levels_distribution = @conference.difficulty_levels_distribution
      @difficulty_levels_distribution_confirmed = @conference.
          difficulty_levels_distribution(:confirmed)

      @tracks_distribution = @conference.tracks_distribution
      @tracks_distribution_confirmed = @conference.tracks_distribution(:confirmed)

      # Recent actions information
      @recent_events = @conference.events.limit(5).order(created_at: :desc)
      @recent_registrations = @conference.registrations.limit(5).order(created_at: :desc)

      @top_submitter = @conference.get_top_submitter

      # get targets
      @registration_targets = @conference.get_targets(Target.units[:registrations])
      @submission_targets = @conference.get_targets(Target.units[:submissions])
      @program_minutes_targets = @conference.get_targets(Target.units[:program_minutes])

      # get campaigns
      @campaigns = @conference.get_campaigns

      respond_to do |format|
        format.html
        format.json { render json: @conference.to_json }
      end
    end

    def edit
      @conferences = Conference.all
      @conference = Conference.find_by(short_title: params[:id])
      respond_to do |format|
        format.html
        format.json { render json: @conference.to_json }
      end
    end
  end
end
