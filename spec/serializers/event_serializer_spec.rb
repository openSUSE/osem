# frozen_string_literal: true

require 'spec_helper'
describe EventSerializer, type: :serializer do
  let(:event) { create(:event, title: 'Some Talk', abstract: 'Lorem ipsum dolor sit amet') }
  let(:serializer) { EventSerializer.new(event) }

  context 'event does not have date, room and tracks assigned' do
    it 'sets guid, title, length, abstract and type' do
      expected_json = {
        guid:           event.guid,
        title:          'Some Talk',
        length:         30,
        scheduled_date: '',
        language:       nil,
        abstract:       'Lorem ipsum dolor sit amet',
        speaker_ids:    event.speaker_ids,
        type:           'Example Event Type',
        room:           nil,
        track:          nil
      }.to_json

      expect(serializer.to_json).to eq expected_json
    end
  end

  context 'event has date, speakers, room and tracks assigned' do
    let(:speaker) { create(:user) }
    let(:room) { create(:room) }
    let(:track) { create(:track) }

    before do
      event.language = 'English'
      event.speakers = [speaker]
      create(:event_schedule, event: event, room: room, start_time: Date.new(2014, 03, 04) + 9.hours)
      event.track = track
    end

    it 'sets guid, title, length, abstract, type, date, language, speakers, room and track' do
      expected_json = {
        guid:           event.guid,
        title:          'Some Talk',
        length:         30,
        scheduled_date: ' 2014-03-04T09:00:00+0000 ',
        language:       'English',
        abstract:       'Lorem ipsum dolor sit amet',
        speaker_ids:    [speaker.id],
        type:           'Example Event Type',
        room:           room.guid,
        track:          track.guid
      }.to_json

      expect(serializer.to_json).to eq expected_json
    end
  end
end
