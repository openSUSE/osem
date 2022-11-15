
  module Conferences
    class ShowVariablesFetcher
      def initialize(conference: nil)
        @conference = conference
        @cfps = @conference&.program&.cfps
        @splashpage = @conference&.splashpage
      end
    
      def conference_image_url(request)
        "#{request.protocol}#{request.host}#{conference.picture}"
      end
    
      def event_types_and_track_names(call_for_events)
        [event_types, track_names] if call_for_events.try(:open?)
      end
    
      def cfp_call_by_type(type)
        @cfps.find { |call| call.cfp_type == type }
      end
    
      def fetch_tracks
        tracks if @splashpage.include_tracks
      end
    
      def fetch_booths
        booths if @splashpage.include_booths
      end
    
      def fetch_tickets
        if @splashpage.include_registrations || @splashpage.include_tickets
          tickets
        end
      end
    
      def fetch_lodgings
        lodgings if @splashpage.include_lodgings
      end
    
      def sponsorship_levels
        Queries::Conferences.new(conference: conference).sponsorship_levels
      end
    
      private
      
      attr :conference

      def lodgings
        conference.lodgings.order('name')
      end
    
      def track_names
        conference.confirmed_tracks.pluck(:name).sort
      end
    
      def event_types
        conference.event_types.pluck(:title)
      end
    
      def tracks
        Queries::Conferences.new(conference: conference).confirmed_tracks
      end
    
      def booths
        conference.confirmed_booths.order('title')
      end
    
      def tickets
        conference.tickets.order('price_cents')
      end
    end
  end
