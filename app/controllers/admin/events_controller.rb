class Admin::EventsController < ApplicationController
  before_filter :verify_organizer
  layout "admin"

  def index
    @events = @conference.events
  end

  def show
    @event = @conference.events.find(params[:id])
    @comments = @event.root_comments
    @comment_count = @event.comment_threads.count
  end

  def edit
    @event_types = @conference.event_types
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

    redirect_to admin_conference_event_path(:conference_id => @conference.short_title, :id => params[:id])
  end
  def create

  end

  def update_state
    event = Event.find(params[:id])
    event.send(:"#{params[:transition]}!", :send_mail => params[:send_mail])
    redirect_to(admin_conference_events_path(:conference_id => @conference.short_title), :notice => "Updated state")
  end
end
