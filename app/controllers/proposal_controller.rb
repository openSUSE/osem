class ProposalController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :new, :create]
  load_resource :conference, find_by: :short_title
  load_and_authorize_resource :event, parent: false, through: :conference

  def index
    @events = current_user.proposals(@conference)
  end

  def show
    # FIXME: We should show more than the first speaker
    @speaker = @event.speakers.first || @event.submitter
  end

  def new
    @user = User.new
    @url = conference_proposal_index_path(@conference.short_title)
  end

  def edit
    authorize! :edit, @event
    @url = conference_proposal_path(@conference.short_title, params[:id])
  end

  def create
    @url = conference_proposal_index_path(@conference.short_title)

    unless current_user
      @user = User.new(params[:user])
      if @user.save
        sign_in(@user)
      else
        flash[:error] = "Could not save user: #{@user.errors.full_messages.join(', ')}"
        render action: 'new'
        return
      end
    end

    params[:event].delete :user

    @event = Event.new(params[:event])
    @event.conference = @conference

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

    flash[:notice] = 'Proposal was successfully submitted.'
    redirect_to conference_proposal_index_path(@conference.short_title)
  end

  def update
    authorize! :update, @event
    @url = conference_proposal_path(@conference.short_title, params[:id])

    # First, update the submitter's info, if they've changed anything
    current_user.assign_attributes(params[:user])
    if current_user.changed?
      current_user.save
    end

    # FIXME: Hmmmmm
    params[:event].delete :users_attributes
    params[:event].delete :user

    if !@event.update(params[:event])
      flash[:error] = "Could not update proposal: #{@event.errors.full_messages.join(', ')}"
      render action: 'new'
      return
    end

    flash[:notice] = 'Proposal was successfully updated.'
    redirect_to conference_proposal_index_path(conference_id: @conference.short_title)
  end

  def destroy
    authorize! :destroy, @event
    @url = conference_proposal_path(@conference.short_title, params[:id])

    begin
      @event.withdraw
    rescue Transitions::InvalidTransition
      redirect_to(:back, error: "Event can't be withdrawn")
      return
    end

    @event.save(validate: false)
    flash[:notice] = 'Proposal was successfully withdrawn.'
    redirect_to conference_proposal_index_path(conference_id: @conference.short_title)
  end

  def confirm
    authorize! :update, @event
    @url = conference_proposal_path(@conference.short_title, params[:id])

    begin
      @event.confirm!
    rescue Transitions::InvalidTransition
      redirect_to(:back, error: "Event can't be confirmed")
      return
    end

    if !@event.save
      flash[:error] = "Could not confirm proposal: #{@event.errors.full_messages.join(', ')}"
      render action: 'new'
      return
    end

    if @conference.user_registered?(current_user)
      flash[:notice] = 'The proposal was confirmed.'
      redirect_to conference_proposal_index_path(@conference.short_title)
    else
      flash[:error] = 'The proposal was confirmed. Please register to attend the conference.'
      redirect_to new_conference_conference_registrations_path(conference_id: @conference.short_title)
    end
  end

  def restart
    authorize! :update, @event
    @url = conference_proposal_path(@conference.short_title, params[:id])

    begin
      @event.restart
    rescue Transitions::InvalidTransition
      flash[:error] = "The proposal can't be re-submitted."
      redirect_to conference_proposal_index_path(conference_id: @conference.short_title)
      return
    end

    if !@event.save
      flash[:error] = "Could not re-submit proposal: #{@event.errors.full_messages.join(', ')}"
      render action: 'new'
      return
    end

    flash[:notice] = "The proposal was re-submitted. The #{@conference.short_title} organizers will review it again."

    redirect_to conference_proposal_index_path(conference_id: @conference.short_title)
  end
end

# FIXME: Introduce strong_parameters pronto!
