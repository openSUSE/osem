require 'spec_helper'

describe Event do

  describe 'abstract_word_count' do
    it 'counts words in abstract' do
      event = build(:event)
      expect(event.abstract_word_count).to eq(233)
      event.update_attributes!(abstract: 'abstract.')
      expect(event.abstract_word_count).to eq(1)
    end

    it 'counts 0 when abstract is empty' do
      event = build(:event, abstract: nil)
      expect(event.abstract_word_count).to eq(0)
      event.abstract = ''
      expect(event.abstract_word_count).to eq(0)
    end
  end

  describe 'as_json' do
    let(:event) { create(:event) }

    it 'adds the event\'s room_guid, track_color and length' do
      event.room = create(:room)
      event.track = create(:track, color: '#efefef')
      json_hash = event.as_json(nil)

      expect(json_hash[:room_guid]).to eq(event.room.guid)
      expect(json_hash[:track_color]).to eq('#efefef')
      expect(json_hash[:length]).to eq(30)
    end

    it 'uses correct default values for room_guid, track_color and length' do
      event.event_type = nil
      json_hash = event.as_json(nil)

      expect(json_hash[:room_guid]).to be_nil
      expect(json_hash[:track_color]).to eq('#ffffff')
      expect(json_hash[:length]).to eq(25)
    end
  end
end
