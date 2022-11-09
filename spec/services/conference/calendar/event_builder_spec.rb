# frozen_string_literal: true

require 'spec_helper'

describe Conference::Calendar::EventBuilder, type: :serializer do
  describe '.call' do
    let(:conference_url) { 'www.sample.com' }
    let!(:calendar) { Icalendar::Calendar.new }
    let(:conference) { create :full_conference }
    
    context 'when is a full calendar' do
      let(:proposals_calendar) { double(:proposals_calendar) }

      setup do
        allow_any_instance_of(ConferenceHelper)
          .to receive(:icalendar_proposals)
          .and_return(proposals_calendar)
      end
    
      it 'returns icalendar_proposals' do
        result = described_class.call(
          conference: conference, 
          calendar: calendar, 
          is_full_calendar: true, 
          conference_url: conference_url
        )

        expect(result).to eq(proposals_calendar)
      end
    end

    context 'when is a not full calendar' do
      let(:venue) { conference.venue }
      setup do
        venue.update(latitude: '-100', longitude:'-200')
      end
      
      it 'set callendar params' do
        calendar = Icalendar::Calendar.new
        described_class.call(
          conference: conference, 
          calendar: calendar, 
          is_full_calendar: false, 
          conference_url: conference_url
        )
        event = calendar.events.first
      
        expect(event.location).to eq("#{venue.street}, #{venue.postalcode} #{venue.city}, #{venue.country_name}")
        expect(event.dtstart).to eq(conference.start_date)
        expect(event.dtstart.ical_params).to eq({ 'VALUE'=>'DATE' })
        expect(event.dtend).to eq(conference.end_date)
        expect(event.dtend.ical_params).to eq({ 'VALUE'=>'DATE' })
        expect(event.duration.present?).to eq(true)
        expect(event.created).to eq(conference.created_at)
        expect(event.last_modified).to eq(conference.updated_at)
        expect(event.summary).to eq(conference.title)
        expect(event.description).to eq(conference.description)
        expect(event.uid).to eq(conference.guid)
        expect(event.url.value_ical).to eq(conference_url)
        expect(event.geo).to eq([conference.venue.latitude.to_f, conference.venue.longitude.to_f])
      end 
    end
  end
end
