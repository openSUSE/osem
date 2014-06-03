class Admin::ConferenceController < ApplicationController
  before_filter :verify_organizer

  def index
    @total_user = User.count
    @new_user = User.where('created_at > ?', current_user.last_sign_in_at).count

    @total_reg = Registration.count
    @new_reg = Registration.where('created_at > ?', current_user.last_sign_in_at).count

    @total_submissions = Event.count
    @new_submissions = Event.where('created_at > ?', current_user.last_sign_in_at).count

    @conferences = Conference.select('id, short_title, color, start_date,
                                      registration_end_date, registration_start_date')

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

    # Redirect to new form if there is no conference
    if Conference.count == 0
      redirect_to new_admin_conference_path
      return
    end
  end

  def new
    @conference = Conference.new
  end

  def create
    @conference = Conference.new(params[:conference])
    if @conference.valid?
      @conference.save
      redirect_to(admin_conference_path(id: @conference.short_title),
                  notice: 'Conference was successfully created.')
    else
      redirect_to(new_admin_conference_path,
                  alert: 'Creating the Conference failed.' \
                          "#{@conference.errors.full_messages.join('. ')}.")
    end
  end

  def update
    @conference = Conference.find_by(short_title: params[:id])
    short_title = @conference.short_title
    if @conference.update_attributes(params[:conference])
      redirect_to(edit_admin_conference_path(id: @conference.short_title),
                  notice: 'Conference was successfully updated.')
    else
      redirect_to(edit_admin_conference_path(id: short_title),
                  alert: 'Updating conference failed. ' \
                  "#{@conference.errors.full_messages.join('. ')}.")
    end
  end

  def show
    @conference = Conference.find_by(short_title: params[:id])
    @conference_progress = @conference.get_status
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
