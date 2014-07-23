module Admin
  class EventsController < ApplicationController
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
      @machine_states = @events.state_machine.states.map
      @event_types = @conference.event_types

      @mystates = []
      @mytypes = []
      @eventstats = {}
      @totallength = 0

      @machine_states.each do |mystate|
        length = 0
        events_mystate = @events.where('state' => mystate.name)
        if events_mystate.count > 0
          @mystates << mystate
          events_mystate.each do |myevent|
            length += myevent.event_type.length
          end
          @eventstats["#{mystate.name}"] = { 'count' => events_mystate.count, 'length' => length }
        end
      end

      @event_types.each do |mytype|
        events_mytype = @events.where('event_type_id' => mytype.id)
        if events_mytype.count > 0
          @mytypes << mytype
        end
      end
      @mytypes.each do |mytype|
        @mystates.each do |mystate|
          events_mytype = @events.where('event_type_id' => mytype.id)
          events_mytype_mystate = events_mytype.where('state' => mystate.name)
          typelength = 0
          if events_mytype_mystate.count > 0
            events_mytype_mystate.each do |myevent|
              typelength += myevent.event_type.length
              @totallength += myevent.event_type.length
            end

            if @eventstats[mytype.title].nil?
              @eventstats[mytype.title] = { 'count' => events_mytype.count,
                                            'length' => events_mytype.count * mytype.length }
            end

            tmp = { "#{mystate.name}" => { 'type_state_count' => events_mytype_mystate.count,
                                           'type_state_length' => typelength } }
            @eventstats[mytype.title].merge!(tmp)
          end
        end
      end
      @eventstats['totallength'] = @totallength

      respond_to do |format|
        format.html
        # Explicity call #to_json to avoid the use of EventSerializer
        format.json { render json: Event.where(state: :confirmed).to_json }
      end
    end

    def show
      @event = @conference.events.find(params[:id])
      @tracks = @conference.tracks
      @event_types = @conference.event_types
      @comments = @event.root_comments
      @comment_count = @event.comment_threads.count
      @ratings = @event.votes.includes(:user)
      @difficulty_levels = @conference.difficulty_levels
    end

    def edit
      @event = @conference.events.find(params[:id])
      @event_types = @conference.event_types
      @tracks = Track.all
      @comments = @event.root_comments
      @comment_count = @event.comment_threads.count
      @user = @event.submitter
      @url = admin_conference_event_path(@conference.short_title, @event)
    end

    def comment
      event = @conference.events.find_by_id(params[:id])
      comment = Comment.build_from(event, current_user.id, params[:comment])
      comment.save!
      if !params[:parent].nil?
        comment.move_to_child_of(params[:parent])
      end

      redirect_to admin_conference_event_path(conference_id: @conference.short_title)
    end

    def update
      @event = Event.find(params[:id])
      if params.has_key? :track_id
        @event.update_attribute(:track_id, params[:track_id])
      end
      if params.has_key? :event_type_id
        @event.update_attribute(:event_type_id, params[:event_type_id])
      end
      if params.has_key? :difficulty_level_id
        @event.update_attribute(:difficulty_level_id, params[:difficulty_level_id])
      end

      if @event.submitter.update_attributes!(params[:user]) && @event.
                                                               update_attributes!(params[:event])
        flash[:notice] = "Successfully updated #{@event.title}."
      else
        flash[:notice] = 'Update not successful.'
      end

      redirect_back_or_to(admin_conference_event_path(@conference.short_title, @event))
    end

    def create
    end

    def accept
      update_state(params[:id], :accept, 'Event accepted!', true)
    end

    def confirm
      update_state(params[:id], :confirm, 'Event confirmed!')
    end

    def cancel
      update_state(params[:id], :cancel, 'Event canceled!')
    end

    def reject
      update_state(params[:id], :reject, 'Event rejected!', true)
    end

    def restart
      update_state(params[:id], :restart, 'Review started!')
    end

    def vote
      @event = Event.find(params[:id])
      @ratings = @event.votes.includes(:user)

      if (votes = current_user.votes.find_by_event_id(params[:id]))
        votes.update_attributes(rating: params[:rating])
      else
        @myvote = @event.votes.build
        @myvote.user = current_user
        @myvote.rating = params[:rating]
        @myvote.save
      end

      respond_to do |format|
        format.html { redirect_to admin_conference_event_path(@conference.short_title, @event) }
        format.js
      end
    end

    private

    def update_state(id, transition, notice, mail = false)
      event = Event.find(id)
      if mail
        check_mail_settings(event)
      end
      if event
        begin
          if mail
            event.send(transition,
                       send_mail: params[:send_mail])
          else
            event.send(transition)
          end
          event.save
        rescue Transitions::InvalidTransition => e
          redirect_to(
              admin_conference_events_path(conference_id: @conference.short_title),
              notice: "Update state failed. #{e.message}") && return
        end
        redirect_to(admin_conference_events_path(conference_id: @conference.short_title),
                    notice: notice)
      else
        redirect_to(admin_conference_events_path(conference_id: @conference.short_title),
                    notice: 'Error! Could not find event!')
      end
    end

    def check_mail_settings(event)
      if !params[:send_mail].blank? && event &&
          event.conference.email_settings.rejected_email_template.nil? &&
          event.conference.email_settings.accepted_email_template.nil?
        redirect_to(admin_conference_events_path(conference_id: @conference.short_title),
                    notice: 'Update Email Template before Sending Mails') && return
      end
    end
  end
end
