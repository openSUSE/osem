class Admin::EventsController < ApplicationController
  before_filter :verify_organizer
  # FIXME: The timezome should only be applied on output, otherwise
  # you get lost in timezone conversions...
  # around_filter :set_timezone_for_this_request

  def set_timezone_for_this_request(&block)
    Time.use_zone(@conference.timezone, &block)
  end

  def index
    @events = @conference.events
    @tracks = @conference.tracks
    @event_states = @events.state_machine.states.map
    respond_to do |format|
      format.html
      # Explicity call #to_json to avoid the use of EventSerializer
      format.json { render :json => Event.where(:state => :confirmed).to_json }
    end
  end

  def show
    @event = @conference.events.find(params[:id])
    @tracks = @conference.tracks
    @event_types = @conference.event_types
    @comments = @event.root_comments
    @comment_count = @event.comment_threads.count
  end

  def edit
    @event = @conference.events.find(params[:id])
    @event_types = @conference.event_types
    @tracks = Track.all
    @comments = @event.root_comments
    @comment_count = @event.comment_threads.count

    @event = Event.find_by_id(params[:id])
    @person = @event.submitter
    @url = edit_admin_conference_event_path(@conference.short_title, @event)
  end

  def comment
    event = @conference.events.find_by_id(params[:id])
    comment = Comment.build_from(event, current_user.id, params[:comment])
    comment.save!
    if !params[:parent].nil?
      comment.move_to_child_of(params[:parent])
    end

    redirect_to admin_conference_event_path(:conference_id => @conference.short_title)
  end

  def update
    @event = Event.find(params[:id])
    if params.has_key? :track_id
      @event.update_attribute(:track_id, params[:track_id])
    end
    if params.has_key? :event_type_id
      @event.update_attribute(:event_type_id, params[:event_type_id])
    end
    expire_page :controller => '/schedule', :action => :index
    redirect_back_or_to(admin_conference_event_path(@conference.short_title, @event), :notice => "Updated")
  end

  def create
    expire_page :controller => '/schedule', :action => :index
  end

  def update_state
    event = Event.find(params[:id])
    event.send(:"#{params[:transition]}!", :send_mail => params[:send_mail])
    expire_page :controller => '/schedule', :action => :index
    redirect_to(admin_conference_events_path(:conference_id => @conference.short_title), :notice => "Updated state")
  end
end
