class ProposalController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :new, :create]
  load_resource :conference, find_by: :short_title
  load_resource :program, through: :conference, singleton: true
  load_and_authorize_resource :event, parent: false, through: :program, except: [:new, :create]

  def index
    @event = @program.events.new
    @event.event_users.new(user: current_user, event_role: 'submitter')
    @events = current_user.proposals(@conference)
  end

  def show
    # FIXME: We should show more than the first speaker
    @speaker = @event.speakers.first || @event.submitter
  end

  def new
    @event = @program.events.new
    @event.event_users.new(user: current_user, event_role: 'submitter') if current_user
    authorize! :new, @event
    @user = User.new
    @url = conference_program_proposal_index_path(@conference.short_title)
  end

  def edit
    @url = conference_program_proposal_path(@conference.short_title, params[:id])
  end

  def create
    @url = conference_program_proposal_index_path(@conference.short_title)

    # We allow proposal submission and sign up on same page.
    # If user is not signed in then first create new user and then sign them in
    unless current_user
      @user = User.new(user_params)
      authorize! :create, @user
      if @user.save
        sign_in(@user)
      else
        flash[:error] = "Could not save user: #{@user.errors.full_messages.join(', ')}"
        render action: 'new'
        return
      end
    end

    params[:event].delete :user

    @event = Event.new(event_params)
    @event.program = @program

    # User which creates the proposal is both `submitter` and `speaker` of proposal
    # by default.
    # TODO: Allow submitter to add speakers to proposals
    @event.event_users.new(user: current_user,
                           event_role: 'submitter')
    @event.event_users.new(user: current_user,
                           event_role: 'speaker')
    authorize! :new, @event

    if @event.save
      ahoy.track 'Event submission', title: 'New submission'
      redirect_to conference_program_proposal_index_path(@conference.short_title), notice: 'Proposal was successfully submitted.'
    else
      flash[:error] = "Could not submit proposal: #{@event.errors.full_messages.join(', ')}"
      render action: 'new'
    end
  end

  def update
    @url = conference_program_proposal_path(@conference.short_title, params[:id])

    if @event.update(event_params)
      redirect_to conference_program_proposal_index_path(conference_id: @conference.short_title),
                  notice: 'Proposal was successfully updated.'
    else
      flash[:error] = "Could not update proposal: #{@event.errors.full_messages.join(', ')}"
      render action: 'edit'
    end
  end

  def withdraw
    authorize! :update, @event
    @url = conference_program_proposal_path(@conference.short_title, params[:id])

    begin
      @event.withdraw
    rescue Transitions::InvalidTransition
      redirect_to :back, error: "Event can't be withdrawn"
      return
    end

    if @event.save
      redirect_to conference_program_proposal_index_path(conference_id: @conference.short_title),
                  notice: 'Proposal was successfully withdrawn.'
    else
      redirect_to conference_program_proposal_index_path(conference_id: @conference.short_title),
                  error: "Could not withdraw proposal: #{@event.errors.full_messages.join(', ')}"
    end
  end

  def confirm
    authorize! :update, @event
    @url = conference_program_proposal_path(@conference.short_title, params[:id])

    begin
      @event.confirm
    rescue Transitions::InvalidTransition
      redirect_to :back, error: "Event can't be confirmed"
      return
    end

    unless @event.save
      redirect_to conference_program_proposal_index_path(conference_id: @conference.short_title),
                  error: "Could not confirm proposal: #{@event.errors.full_messages.join(', ')}"
      return
    end

    if @conference.user_registered?(current_user)
      redirect_to conference_program_proposal_index_path(@conference.short_title),
                  notice: 'The proposal was confirmed.'
    else
      redirect_to new_conference_conference_registrations_path(conference_id: @conference.short_title),
                  alert: 'The proposal was confirmed. Please register to attend the conference.'
    end
  end

  def restart
    authorize! :update, @event
    @url = conference_program_proposal_path(@conference.short_title, params[:id])

    begin
      @event.restart
    rescue Transitions::InvalidTransition
      redirect_to conference_program_proposal_index_path(conference_id: @conference.short_title),
                  error: "The proposal can't be re-submitted."
      return
    end

    if @event.save
      redirect_to conference_program_proposal_index_path(conference_id: @conference.short_title),
                  notice: "The proposal was re-submitted. The #{@conference.short_title} organizers will review it again."
    else
      redirect_to conference_program_proposal_index_path(conference_id: @conference.short_title),
                  error: "Could not re-submit proposal: #{@event.errors.full_messages.join(', ')}"
    end
  end

  private

  def event_params
    params.require(:event).permit(:title, :subtitle, :track_id, :event_type_id, :abstract, :description, :require_registration, :difficulty_level_id)
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :username)
  end
end
