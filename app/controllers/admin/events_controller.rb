class Admin::EventsController < ApplicationController
  before_filter :verify_organizer
  layout "admin"
  around_filter :set_timezone_for_this_request

  def set_timezone_for_this_request(&block)
    Time.use_zone(@conference.timezone, &block)
  end

  def index
    @events = @conference.events
    respond_to do |format|
      format.html
      format.json { render :json => Event.where(:state => :confirmed) }
    end
  end

  def show
    @event = @conference.events.find(params[:id])
    @tracks = Track.all
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
    redirect_to(admin_conference_event_path(@conference.short_title, @event), :notice => "Updated")
  end

  def create

  end

  def update_state
    event = Event.find(params[:id])
    event.send(:"#{params[:transition]}!", :send_mail => params[:send_mail])
    redirect_to(admin_conference_events_path(:conference_id => @conference.short_title), :notice => "Updated state")
  end
end
