class Admin::ConferenceController < ApplicationController
  before_filter :verify_organizer

  def index
    @conferences = Conference.select('id, short_title, color, start_date')

    # Event submissions over time
    @weeks = CallForPapers.max_weeks
    @result = {}

    @conferences.each do |c|
      submission = c.get_submissions_per_week(@weeks)
      @result[c.short_title] = submission
    end

    @weeks = @weeks > 0 ? (1..@weeks).to_a : 1

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
