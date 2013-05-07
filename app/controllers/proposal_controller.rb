class ProposalController < ApplicationController
  before_filter :verify_user
  before_filter :setup
  before_filter :verify_access, :only => [:edit, :update, :destroy, :confirm]

  def setup
    @person = current_user.person
    @url = conference_proposal_index_path(@conference.short_title)
    @event_types = @conference.event_types
  end

  def verify_access
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
    @events = @person.proposals @conference
  end

  def destroy
    @person.withdraw_proposal(params[:id])
    redirect_to(conference_proposal_index_path(:conference_id => @conference.short_title), :alert => 'Proposal withdrawn.')
  end

  def new
    @event = Event.new
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

    if submitter[:public_name].blank?
      redirect_to edit_conference_proposal_path(@conference.short_title, @event), :alert => "Your public name cannot be blank"
      return
    end

    if submitter[:biography].blank?
      redirect_to edit_conference_proposal_path(@conference.short_title, @event), :alert => "Your biography cannot be blank"
      return
    end

    if submitter[:public_name] != @person.public_name || submitter[:biography] != @person.biography
      @person.update_attributes(submitter)
    end

    event = Event.find_by_id(params[:id])

    begin
      event.update_attributes!(params[:event])
      redirect_to(conference_proposal_index_path(:conference_id => @conference.short_title), :notice => "'#{event.title}' was successfully updated.")
    rescue Exception => e
      redirect_to edit_conference_proposal_path(@conference.short_title, @event), :alert => e.message
    end
  end

  def create
    person = current_user.person
    session[:return_to] ||= request.referer

    event_params = params[:event]
    submitter = params[:person]
    params[:event].delete :person

    @event = Event.new(event_params)
    @event.conference = @conference

    if submitter[:public_name].blank?
      flash[:error] = "Your public name cannot be blank."
      render :action => "new"
      return
    end

    if submitter[:biography].blank?
      flash[:error] = "Your biography cannot be blank."
      render :action => "new"
      return
    end

    # First, update the submitter's info, if they've changed anything
    if submitter[:public_name] != person.public_name || submitter[:biography] != person.biography
      person.update_attributes(submitter)
    end

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
    @event = Event.find(params[:id])
  end

  def confirm
    if @event.transition_possible? :confirm
      begin
        @event.confirm!(:send_mail => params[:send_mail])
      rescue Exception => e
        redirect_to(conference_proposal_index_path(:conference_id => @conference.short_title), :alert => "Event was NOT confirmed: #{e.message}")
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
