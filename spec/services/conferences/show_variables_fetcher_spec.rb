# frozen_string_literal: true

require 'spec_helper'

describe Conferences::ShowVariablesFetcher, type: :service do
  describe '.conference_image_url' do
    let(:request) do
      double(protocol: 'protocol', host: 'host')
    end
    let(:conference) do
      build(:conference)
    end

    it 'returns templete string builded' do
      result = described_class.new(conference: conference)
        .conference_image_url(request)
      
      expect(result).to eq(
        "#{request.protocol}#{request.host}#{conference.picture}"
      )
    end
  end

  describe '.event_types_and_track_names' do
    let!(:conference) do
      create :conference
    end
    let(:call_for_events) { double(open?: true) }

    it 'returns an array with event_types and track_names' do
      result = described_class.new(conference: conference)
        .event_types_and_track_names(call_for_events)

      expect(result).to eq([
        conference.event_types.pluck(:title),
        conference.confirmed_tracks.pluck(:name).sort
      ])
    end 
  end

  describe '.cfp_call_by_type' do
    let!(:conference) do
      create :full_conference
    end
    let(:cfp_type) do
      conference.program&.cfps.first.cfp_type
    end

    it 'returns finded cfp by your type' do
      result = described_class.new(conference: conference)
      .cfp_call_by_type(cfp_type)

      expect(result.cfp_type).to eq(cfp_type)
    end
  end

  describe '.fetch_tracks' do
    let!(:conference) do
      create :full_conference
    end
    let(:tracks) { double(:tracks) }
    let(:conferences_query) do
      instance_double(Queries::Conferences, confirmed_tracks: tracks)
    end

    setup do
      allow(Queries::Conferences)
        .to receive(:new)
        .and_return(conferences_query)
    end

    it 'returns tracks' do
      result = described_class.new(conference: conference)
      .fetch_tracks

      expect(result).to eq(tracks)
    end

    it 'calls Queries::Conferences with correct params' do
      expect(Queries::Conferences)
        .to receive(:new)
        .with(conference: conference)

      described_class.new(conference: conference).fetch_tracks
    end
  end

  describe '.fetch_booths' do
    let!(:conference) do
      create :full_conference
    end

    setup do
      conference.splashpage.update!(include_booths: true)
    end

    it 'returns confirmed_booths' do
      result = described_class.new(conference: conference).fetch_booths
   
      expect(result).to eq(conference.confirmed_booths)
    end
  end

  describe '.fetch_tickets' do
    let!(:conference) { create :full_conference }
    let(:splashpage) { conference.splashpage }
    let(:tickets) { double(:tickets) }

    context 'when splashpage#include_registrations is true' do
      setup do
        splashpage.update!(include_registrations: true)
        splashpage.update!(include_tickets: false)
      end

      it 'returns confirmed tickets' do
        result = described_class.new(conference: conference)
          .fetch_tickets

        expect(tickets)
      end
    end

    context 'when splashpage#include_tickets is true' do
      setup do
        splashpage.update!(include_registrations: false)
        splashpage.update!(include_tickets: true)
      end

      it 'returns confirmed tickets' do
        result = described_class.new(conference: conference)
          .fetch_tickets

        expect(tickets)
      end
    end
  end

  describe '.fetch_lodgings' do
    let!(:conference) { create :full_conference }

    it 'returns lodgings' do
      result = described_class.new(conference: conference).fetch_lodgings

      expect(result).to eq(
        conference.lodgings.order('name')
      )
    end
  end

  describe '.sponsorship_levels' do
    let(:sponsorship_levels) { double(:sponsorship_levels) }
    let(:query_instance) do
      instance_double(Queries::Conferences, sponsorship_levels: sponsorship_levels)
    end
    let(:conference) { build(:full_conference) }
    setup do
      allow(Queries::Conferences)
        .to receive(:new)
        .and_return(query_instance)
    end

    it 'returns sponsorship_levels' do
      result = described_class.new(conference: conference).sponsorship_levels

      expect(result).to eq(sponsorship_levels)
    end

    it 'calls Queries::Conferences with correct params' do
      expect(Queries::Conferences)
        .to receive(:new)
        .with(conference: conference)

      described_class.new(conference: conference).sponsorship_levels
    end
  end
end
