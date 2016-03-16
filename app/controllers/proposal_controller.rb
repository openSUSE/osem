class ProposalController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :new, :create]
  load_resource :conference, find_by: :short_title
  load_resource :program, through: :conference, singleton: true
  load_and_authorize_resource :event, parent: false, through: :program

  def index
    @events = current_user.proposals(@conference)
  end

  def show
    # FIXME: We should show more than the first speaker
    @speaker = @event.speakers.first || @event.submitter
  end

  def new
    @user = User.new
    @url = conference_program_proposal_index_path(@conference.short_title)
  end

  def edit
    authorize! :edit, @event
    @url = conference_program_proposal_path(@conference.short_title, params[:id])
  end

  def create
    @url = conference_program_proposal_index_path(@conference.short_title)

    unless current_user
      @user = User.new(user_params)
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

    @event.event_users.new(user: current_user,
                           event_role: 'submitter')
    @event.event_users.new(user: current_user,
                           event_role: 'speaker')

    unless @event.save
      flash[:error] = "Could not submit proposal: #{@event.errors.full_messages.join(', ')}"
      render action: 'new'
      return
    end

    ahoy.track 'Event submission', title: 'New submission'

    redirect_to conference_program_proposal_index_path(@conference.short_title), notice: 'Proposal was successfully submitted.'
  end

  def update
    authorize! :update, @event
    @url = conference_program_proposal_path(@conference.short_title, params[:id])

    if !@event.update(event_params)
      flash[:error] = "Could not update proposal: #{@event.errors.full_messages.join(', ')}"
      render action: 'new'
      return
    end

    redirect_to conference_program_proposal_index_path(conference_id: @conference.short_title),
                notice: 'Proposal was successfully updated.'
  end

  def destroy
    authorize! :destroy, @event
    @url = conference_program_proposal_path(@conference.short_title, params[:id])

    begin
      @event.withdraw
    rescue Transitions::InvalidTransition
      redirect_to :back, error: "Event can't be withdrawn"
      return
    end

    @event.save(validate: false)
    redirect_to conference_program_proposal_index_path(conference_id: @conference.short_title),
                notice: 'Proposal was successfully withdrawn.'
  end

  def confirm
    authorize! :update, @event
    @url = conference_program_proposal_path(@conference.short_title, params[:id])

    begin
      @event.confirm!
    rescue Transitions::InvalidTransition
      redirect_to :back, error: "Event can't be confirmed"
      return
    end

    if !@event.save
      flash[:error] = "Could not confirm proposal: #{@event.errors.full_messages.join(', ')}"
      render action: 'new'
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

    if !@event.save
      flash[:error] = "Could not re-submit proposal: #{@event.errors.full_messages.join(', ')}"
      render action: 'new'
      return
    end

    redirect_to conference_program_proposal_index_path(conference_id: @conference.short_title),
                notice: "The proposal was re-submitted. The #{@conference.short_title} organizers will review it again."
  end

  private

  def event_params
    params.require(:event).permit(:title, :subtitle, :track_id, :event_type_id, :abstract, :description, :require_registration, :difficulty_level_id)
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :username)
  end
end

# FIXME: Introduce strong_parameters pronto!
