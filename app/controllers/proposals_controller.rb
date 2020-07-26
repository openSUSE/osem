# frozen_string_literal: true

class ProposalsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :new, :create]
  load_resource :conference, find_by: :short_title
  load_resource :program, through: :conference, singleton: true
  load_and_authorize_resource :event, parent: false, through: :program
  # We authorize manually in these actions
  skip_authorize_resource :event, only: [:confirm, :restart, :withdraw]

  def index
    @event = @program.events.new
    @event.event_users.new(user: current_user, event_role: 'submitter')
    @events = current_user.proposals(@conference)
    @volunteer_events = current_user.volunteer_duties(@conference)
  end

  def show
    @event_schedule = @event.event_schedules.find_by(schedule_id: @program.selected_schedule_id)
    @speakers_ordered = @event.speakers_ordered
    @surveys_after_event = @event.surveys.after_event.select(&:active?)
  end

  def new
    @user = User.new
    @url = conference_program_proposals_path(@conference.short_title)
    @languages = @program.languages_list
  end

  def edit
    @url = conference_program_proposal_path(@conference.short_title, params[:id])
    @languages = @program.languages_list
  end

  def create
    @url = conference_program_proposals_path(@conference.short_title)

    # We allow proposal submission and sign up on same page.
    # If user is not signed in then first create new user and then sign them in
    unless current_user
      @user = User.new(user_params)
      authorize! :create, @user
      if @user.save
        sign_in(@user)
      else
        flash.now[:error] = "Could not save user: #{@user.errors.full_messages.join(', ')}"
        render action: 'new'
        return
      end
    end

    # User which creates the proposal is both `submitter` and `speaker` of proposal
    # by default.
    @event.speakers = [current_user]
    @event.submitter = current_user

    track = Track.find_by(id: params[:event][:track_id])
    if track && !track.cfp_active
      flash.now[:error] = 'You have selected a track that doesn\'t accept proposals'
      render action: 'new'
      return
    end

    if @event.save
      Mailbot.submitted_proposal_mail(@event).deliver_later if @conference.email_settings.send_on_submitted_proposal
      redirect_to conference_program_proposals_path(@conference.short_title), notice: 'Proposal was successfully submitted.'
    else
      flash.now[:error] = "Could not submit proposal: #{@event.errors.full_messages.join(', ')}"
      render action: 'new'
    end
  end

  def update
    @url = conference_program_proposal_path(@conference.short_title, params[:id])

    track = Track.find_by(id: params[:event][:track_id])
    if track && !track.cfp_active
      flash.now[:error] = 'You have selected a track that doesn\'t accept proposals'
      render action: 'edit'
      return
    end

    if @event.update(event_params)
      redirect_to conference_program_proposals_path(conference_id: @conference.short_title),
                  notice: 'Proposal was successfully updated.'
    else
      flash.now[:error] = "Could not update proposal: #{@event.errors.full_messages.join(', ')}"
      render action: 'edit'
    end
  end

  def withdraw
    authorize! :update, @event
    @url = conference_program_proposal_path(@conference.short_title, params[:id])

    begin
      @event.withdraw
      selected_schedule = @event.program.selected_schedule
      event_schedule = @event.event_schedules.find_by(schedule: selected_schedule) if selected_schedule
      Rails.logger.debug "schedule: #{selected_schedule.inspect} and event_schedule #{event_schedule.inspect}"
      if selected_schedule && event_schedule
        event_schedule.enabled = false
        event_schedule.save
      else
        @event.event_schedules.destroy_all
      end
    rescue Transitions::InvalidTransition
      redirect_back(fallback_location: root_path, error: "Event can't be withdrawn")
      return
    end

    if @event.save
      redirect_to conference_program_proposals_path(conference_id: @conference.short_title),
                  notice: 'Proposal was successfully withdrawn.'
    else
      redirect_to conference_program_proposals_path(conference_id: @conference.short_title),
                  error: "Could not withdraw proposal: #{@event.errors.full_messages.join(', ')}"
    end
  end

  def confirm
    authorize! :update, @event
    @url = conference_program_proposal_path(@conference.short_title, params[:id])

    begin
      @event.confirm
    rescue Transitions::InvalidTransition
      redirect_back(fallback_location: root_path, error: "Event can't be confirmed")
      return
    end

    if @event.save
      if @conference.user_registered?(current_user)
        redirect_to conference_program_proposals_path(@conference.short_title),
                    notice: 'The proposal was confirmed.'
      else
        redirect_to new_conference_conference_registration_path(conference_id: @conference.short_title),
                    alert: 'The proposal was confirmed. Please register to attend the conference.'
      end
    else
      redirect_to conference_program_proposals_path(conference_id: @conference.short_title),
                  error: "Could not confirm proposal: #{@event.errors.full_messages.join(', ')}"
    end
  end

  def restart
    authorize! :update, @event
    @url = conference_program_proposal_path(@conference.short_title, params[:id])

    begin
      @event.restart
    rescue Transitions::InvalidTransition
      redirect_to conference_program_proposals_path(conference_id: @conference.short_title),
                  error: "The proposal can't be re-submitted."
      return
    end

    if @event.save
      redirect_to conference_program_proposals_path(conference_id: @conference.short_title),
                  notice: "The proposal was re-submitted. The #{@conference.short_title} organizers will review it again."
    else
      redirect_to conference_program_proposals_path(conference_id: @conference.short_title),
                  error: "Could not re-submit proposal: #{@event.errors.full_messages.join(', ')}"
    end
  end

  def registrations; end

  private

  def event_params
    params.require(:event).permit(:event_type_id, :track_id, :difficulty_level_id,
                                  :title, :subtitle, :abstract, :description,
                                  :require_registration, :max_attendees, :language,
                                  speaker_ids: [], volunteer_ids: []
                                 )
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :username)
  end
end
