class ProposalController < ApplicationController
  before_filter :verify_user
  before_filter :verify_access, :only => [:edit, :update, :destroy, :confirm]

  def verify_access
    @person = current_user.person
    if params.has_key? :proposal_id
      params[:id] = params[:proposal_id]
    end

    begin
      if !organizer_or_admin?
        @event = @person.events.find(params[:id])
      else
        @event = Event.find(params[:id])
      end
    rescue Exception => e
      Rails.logger.debug("Proposal failure in verify_access: #{e.message}")
      redirect_to(conference_proposal_index_path(:conference_id => @conference.short_title), :alert => 'Invalid or uneditable proposal.')
    end
  end

  def index
    @person = current_user.person
    @events = @person.proposals @conference
  end

  def destroy
    @person.withdraw_proposal(params[:id])
    redirect_to(conference_proposal_index_path(:conference_id => @conference.short_title), :alert => 'Proposal withdrawn.')
  end

  def new
    @url = conference_proposal_index_path(@conference.short_title)
    @event = Event.new
    @event_types = @conference.event_types
    @person = current_user.person
  end

  def edit
    @url = conference_proposal_path(@conference.short_title, params[:id])
    @event_types = @conference.event_types
    @attachments = @event.event_attachments

    if @event.nil? || !@conference.cfp_open? || @event.unconfirmed? || @event.confirmed?
      redirect_to(conference_proposal_index_path(:conference_id => @conference.short_title), :alert => 'Invalid or uneditable proposal.')
    end
  end

  def update
    session[:return_to] ||= request.referer
    submitter = params[:person]

    params[:event].delete :people_attributes
    params[:event].delete :person

    if submitter[:public_name] != @person.public_name || submitter[:biography] != @person.biography
      @person.update_attributes(submitter)
    end

    event = Event.find_by_id(params[:id])

    if event.update_attributes!(params[:event])
      redirect_to(conference_proposal_index_path(:conference_id => @conference.short_title), :notice => "'#{event.title}' was successfully updated.")
    else
      redirect_to session[:return_to], :alert => "'#{event.title}' was NOT updated!"
    end
  end

  def create
    person = current_user.person
    session[:return_to] ||= request.referer

    event_params = params[:event]
    submitter = params[:person]
    params[:event].delete :person

    # First, update the submitter's info, if they've changed anything
    if submitter[:public_name] != person.public_name || submitter[:biography] != person.biography
      person.update_attributes(submitter)
    end

    @event = Event.new(event_params)
    @event.conference = @conference
    @event.event_people.new(:person => person,
                           :event_role => "submitter")
    @event.event_people.new(:person => person,
                           :event_role => "speaker")

    begin
      @event.save!
    rescue Exception => e
      @url = conference_proposal_index_path(@conference.short_title)
      @event_types = @conference.event_types
      @person = current_user.person

      flash[:error] = "Could not submit proposal: #{e.message}"
      render :action => 'new'
      return
    end

    registration = person.registrations.where(:conference_id => @conference.id).first
    if registration.nil?
      redirect_to(register_conference_path(@conference.short_title), :notice => 'Event was successfully submitted. You probably want to register for the conference now!')
    else
      redirect_to(conference_proposal_index_path(:conference_id => @conference.short_title), :notice => 'Event was successfully submitted.')
    end
  end

  def show

  end

  def confirm
    if @event.transition_possible? :confirm
      begin
        @event.confirm!
      rescue Exception => e
        redirect_to(conference_proposal_index_path(:conference_id => @conference.short_title), :alert => 'Event was NOT confirmed: #{e.message}')
        return
      end

      if !@conference.user_registered?(current_user)
        redirect_to(register_conference_path(@conference.short_title), :notice => "Event was confirmed. Please register to attend the conference.")
        return
      end
      redirect_to(conference_proposal_index_path(:conference_id => @conference.short_title), :notice => 'Event was confirmed.')
    else
      redirect_to(conference_proposal_index_path(:conference_id => @conference.short_title), :alert => 'Event was NOT confirmed!')
    end
  end

end
