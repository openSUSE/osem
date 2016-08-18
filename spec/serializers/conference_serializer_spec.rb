require 'spec_helper'

describe ConferenceSerializer, type: :serializer do
  let(:conference) do
    create(:conference, short_title: 'goto',
                        description: 'Lorem ipsum dolor sit',
                        start_date: Date.new(2014, 03, 04),
                        end_date: Date.new(2014, 03, 10))
  end

  let(:serializer) { ConferenceSerializer.new(conference) }

  context 'when the conference does not have rooms and tracks' do
    it 'correctly serializes the conference' do
      expect(serializer.to_json).to match_response_schema('conference')
    end
  end

  context 'when the conference has rooms and tracks' do
    let(:venue) { create(:venue, conference: conference) }
    let!(:room) { create(:room, venue: venue) }
    let!(:track) { create(:track, program: conference.program) }

    it 'correctly serializes the conference' do
      expect(serializer.to_json).to match_response_schema('conference')
    end
  end
end
