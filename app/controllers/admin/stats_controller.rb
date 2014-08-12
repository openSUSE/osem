module Admin
  class StatsController < ApplicationController
    load_and_authorize_resource
    load_and_authorize_resource :conference, find_by: :short_title

    def index
      @registrations = @conference.registrations.includes(:user)
      @registrations = @registrations.order('registrations.created_at ASC')
      @registered = @conference.registrations.count
      @attendees = @conference.registrations.where('attended = ?', true).count
      @pre_registered = @conference.registrations
      @pre_registered = @pre_registered.where('created_at < ?', @conference.start_date).count
      @pre_registered_attended = @conference.registrations.where('created_at < ? AND attended = ?',
                                                                 @conference.start_date, true).count

      @registered_with_partner = @conference.registrations.where('attending_with_partner = ?',
                                                                 true).count
      @attended_with_partner = @conference.registrations.where(
        'attending_with_partner = ? AND attended = ?', true, true).count

      @handicapped_access = @conference.registrations.where(handicapped_access_required: true).count
      @handicapped_access_attended = @conference.registrations.where(handicapped_access_required:
                                                                     true)
      @handicapped_access_attended = @handicapped_access_attended.where(attended: true).count
      @suggested_hotel_stay = @conference.registrations.where('using_affiliated_lodging = ?',
                                                              true).count

      @events = @conference.events
      # Events charts
      @machine_states = [['confirmed'], ['cancelled'], ['rejected'], ['withdrawn'],
                         ['new', 'review'], ['unconfirmed', 'accepted']]
      # Types distribution per state
      @type_state = {}
      @machine_states.each do |state|
        @type_state[state[0]] = var_state_func(@conference.event_types, 'event_type', state)
      end

      # Tracks distribution per state
      @no_track_all = @events.where(track_id: nil)
      @no_track_new = @events.where(track_id: nil).where(state: ['new', 'review'])
      @no_track_unconfirmed = @events.where(track_id: nil).where(state: 'unconfirmed')
      @no_track_confirmed = @events.where(track_id: nil).where(state: 'confirmed')
      @track_state = {}
      @machine_states.each do |state|
        @track_state[state[0]] = var_state_func(@conference.tracks, 'track', state)
      end

      # Events_time chart
      if @events.count > 0
        start_date = @events.minimum('created_at').strftime('%Y-%m-%d')
        end_date = @events.maximum('created_at').strftime('%Y-%m-%d')
        unless start_date.nil? || end_date.nil?
          @events_time = var_time(start_date, end_date, @events, 'created_at')
        end
      end

      # Code for the table in events
      @mystates = []
      @mytypes = []
      @eventstats = {}
      @totallength = 0
      # Get totals per state
      @events.state_machine.states.map.each do |mystate|
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

      @conference.event_types.each do |mytype|
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

      # SPEAKERS stats
      @speakers = User.joins(:events).where('events.conference_id = ? AND events.state LIKE ?',
                                            @conference.id,  'confirmed').uniq
      @speaker_fields_user = %w(name email affiliation)
      @speaker_fields_reg = %w(arrival departure)
      # TICKETS stats
      @supporter_levels = @conference.supporter_levels
      @tickets = @conference.registrations.joins(supporter_registration: :supporter_level)
      @tickets = @tickets.where('supporter_levels.title NOT LIKE ? ', '%Free%')

      @tickets_time = []

      if @conference.registration_start_date && @conference.end_date && @registered > 0 && @supporter_levels
        start_date = @conference.registration_start_date
        end_date = @conference.end_date
        levels = []
        @conference.supporter_levels.each do |level|
          @tickets_time << { 'key' => level.title, 'values' => [] }
          levels << ["#{level.title}"]
        end

        (start_date..end_date).each do |day|
          if @tickets.where('supporter_registrations.created_at LIKE ?', "%#{day}%").where(
           'supporter_levels.title' => levels).count != 0
            @conference.supporter_levels.each do |level|

              day_ticket_count = @tickets.where('supporter_registrations.created_at LIKE ?
                                                 AND supporter_levels.title LIKE ?',
                                                "%#{day}%", "%#{level.title}%").count

              index = @tickets_time.index { |v| v['key'] == "#{level.title}" }
              @tickets_time[index]['values'] << { 'label' => "#{day}", 'value' => day_ticket_count }
            end
          end
        end
      end
      @tickets_distribution = []
      @tickets_time.each do |ticket|
        value = ticket['values'].map { |x| x['value'] }.sum
        percent = (value.to_f / @tickets.count * 100).round(2)
        @tickets_distribution << { 'status' => ticket['key'],
                                   'value' => value, 'percent' => percent }
      end

      # OTHER_INFO chart / To be 'Questions'
      @other_info = [
        { 'status' => 'with partner (registered)', 'value' => @registered_with_partner },
        { 'status' => 'with partner (attended)', 'value' => @attended_with_partner },
        { 'status' => 'handicapped (registered)', 'value' => @handicapped_access },
        { 'status' => 'handicapped (attended)', 'value' => @handicapped_access_attended },
        { 'status' => 'stay at suggested hotel', 'value' => @suggested_hotel_stay }
      ]

      # REGISTRATIONS, registered_time
      if @conference.registration_start_date && @conference.end_date && @registered > 0
        start_date = @conference.registration_start_date
        end_date = @conference.end_date
        @registered_time = var_time(start_date, end_date, @registrations, 'created_at')
      end

      respond_to do |format|
        format.html
        format.json { render json: @tickets_time.to_json }
      end
    end
    # FUNCTIONS
    def var_time(start_date, end_date, var, field)
      result = []
      (start_date..end_date).each do |day|
        day_var_count = var.where("#{field} LIKE ?", "%#{day}%").count
        if day_var_count != 0
          result << { 'status' => "#{day}", 'value' => day_var_count }
        end
      end
      result
    end

    def var_state_func(vars, field, mystate)
      result = []

      vars.each do |myvar|
        # Find events per track and state
        value = @conference.events.where("#{field}_id" => myvar.id).where(state: mystate).count
        # Find all events in that state
        total = @conference.events.where(state: mystate).count
        status = "#{myvar.name}"

        percent = 0 # rubocop:disable Lint/UselessAssignment
        if value != 0
          percent = (value.to_f / total * 100).round(2)
          result << { 'status' => status, 'value' => value, 'percent' => percent }
        end
      end
      # Get no of events for which the field is not set (So that pie shows half piece for 50%)
      sum = result.inject(0) { |s, hash| s + hash['value'] }
      value = total - sum
      if sum != 0 && value != 0
        percent = (value.to_f / total * 100).round(2)
        result << { 'status' => "no #{field} set", 'value' => value, 'percent' => percent }
      end

      result
    end

    def speaker_reg(speaker)
      speaker.registrations.where('conference_id = ? AND user_id = ?',
                                  @conference.id, speaker.id).first
    end

    def speaker_diet(reg)
      @conference.dietary_choices.find(reg.dietary_choice_id)
    end

    def diet_count(diet)
      @conference.registrations.where('dietary_choice_id = ?', diet)
    end

    def social_event_count(event)
      @conference.registrations.joins(:social_events).where(
        'registrations_social_events.social_event_id = ?', event).count
    end

    helper_method :speaker_reg
    helper_method :speaker_diet
    helper_method :diet_count
    helper_method :social_event_count
  end
end

