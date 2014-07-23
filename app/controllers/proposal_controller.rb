class ProposalController < ApplicationController
  before_filter :verify_user, except: [:show]
  before_filter :setup
  before_filter :verify_access, only: [:edit, :update, :destroy, :confirm, :restart]

  def setup
    @user = current_user if current_user
    # FIXME: @conference also comes from verify_user, but we need setup also in show
    # which can be accessed anonymusly
    @conference = Conference.find_by(short_title: params[:conference_id])
    @url = conference_proposal_index_path(@conference.short_title)
    @event_types = @conference.event_types
  end

  def verify_access
    if params.has_key? :proposal_id
      params[:id] = params[:proposal_id]
    end

    begin
      if !organizer_or_admin?
        @event = @user.events.find(params[:id])
      else
        @event = Event.find(params[:id])
      end
    rescue => e
      Rails.logger.debug("Proposal failure in verify_access: #{e.message}")
      redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                  alert: 'Invalid or uneditable proposal.')
    end
  end

  def index
    @events = @user.proposals @conference
  end

  def destroy
    proposal = @user.events.find_by_id(params[:id])
    if proposal
      proposal.withdraw
      proposal.save
      redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                  alert: 'Proposal withdrawn.')
    else
      redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                  alert: 'Error! Could not find proposal!')
    end
  end

  def new
    @event = Event.new
  end

  def edit
    @url = conference_proposal_path(@conference.short_title, params[:id])
    @event_types = @conference.event_types
    @attachments = @event.event_attachments

    if @event.nil?
      redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                  alert: 'Invalid or uneditable proposal.')
    end
  end

  def update
    session[:return_to] ||= request.referer
    submitter = params[:user]

    params[:event].delete :users_attributes
    params[:event].delete :user

    if submitter[:name].blank?
      redirect_to edit_conference_proposal_path(@conference.short_title, @event),
                  alert: 'Your name cannot be blank'
      return
    end

    if submitter[:biography].blank?
      redirect_to edit_conference_proposal_path(@conference.short_title, @event),
                  alert: 'Your biography cannot be blank'
      return
    end

    if submitter[:name] != @user.name || submitter[:biography] != @user.biography
      @user.update_attributes(submitter)
    end

    event = Event.find_by_id(params[:id])

    begin
      event.update_attributes!(params[:event])
      redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                  notice: "'#{event.title}' was successfully updated.")
    rescue => e
      redirect_to edit_conference_proposal_path(@conference.short_title, @event), alert: e.message
    end
  end

  def create
    user = current_user
    session[:return_to] ||= request.referer

    event_params = params[:event]
    submitter = params[:user]
    params[:event].delete :user

    @event = Event.new(event_params)
    @event.conference = @conference

    if submitter[:name].blank?
      flash[:error] = 'Your public name cannot be blank.'
      render action: 'new'
      return
    end

    if submitter[:biography].blank?
      flash[:error] = 'Your biography cannot be blank.'
      render action: 'new'
      return
    end

    # First, update the submitter's info, if they've changed anything
    if submitter[:name] != user.name || submitter[:biography] != user.biography
      user.update_attributes(submitter)
    end

    @event.event_users.new(user: user,
                           event_role: 'submitter')
    @event.event_users.new(user: user,
                           event_role: 'speaker')

    begin
      @event.save!
    rescue => e
      @url = conference_proposal_index_path(@conference.short_title)
      @event_types = @conference.event_types
      @user = current_user

      flash[:error] = "Could not submit proposal: #{e.message}"
      render action: 'new'
      return
    end

    registration = user.registrations.where(conference_id: @conference.id).first
    ahoy.track 'Event submission', title: 'New submission'
    if registration.nil?
      redirect_to(register_conference_path(@conference.short_title),
                  notice: 'Event was successfully submitted.\
                 You probably want to register for the conference now!')
    else
      redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                  notice: 'Event was successfully submitted.')
    end
  end

  def show
    @event = Event.find(params[:id])
    @speaker = @event.speakers.first || @event.submitter
  end

  def confirm
    if @event.transition_possible? :confirm
      begin
        @event.confirm!
      rescue InvalidTransition => e
        redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                    alert: "Event was NOT confirmed: #{e.message}")
        return
      end

      if !@conference.user_registered?(current_user)
        redirect_to(register_conference_path(@conference.short_title),
                    notice: 'Event was confirmed. Please register to attend the conference.')
        return
      end
      redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                  notice: 'Event was confirmed.')
    else
      redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                  alert: 'Event was NOT confirmed!')
    end
  end

  def restart
    if @event.transition_possible? :restart
      begin
        @event.restart
        @event.save
      rescue InvalidTransition => e
        redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                    alert: "Event was NOT restarted: #{e.message}")
        return
      end
      # Success
      redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                  notice: 'Event was restarted. Review pending!')
    else
      # Error
      redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                  alert: 'Event was NOT restarted!')
    end
  end
end
