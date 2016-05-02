require 'spec_helper'
describe ConferenceSerializer, type: :serializer do
  let(:conference) do
    create(:conference, short_title: 'goto',
                        description: 'Lorem ipsum dolor sit',
                        start_date: Date.new(2014, 03, 04),
                        end_date: Date.new(2014, 03, 10))
  end

  let(:serializer) { ConferenceSerializer.new(conference) }
  let(:expected_hash) do
    {
      conference: {
        short_title: 'goto',
        title: conference.title,
        description: 'Lorem ipsum dolor sit',
        start_date: '2014-03-04',
        end_date: '2014-03-10',
        picture_url: nil,
        difficulty_levels:
          [{id: 1,
            title: 'Easy',
            description: 'Events are understandable for everyone without knowledge of the topic.'
           },
           {id: 2,
            title: 'Medium',
            description: 'Events require a basic understanding of the topic.'
           },
           {id: 3,
            title: 'Hard',
            description: 'Events require expert knowledge of the topic.'
           }
          ],
        event_types:
          [{id: 1,
            title: 'Talk',
            length: 30,
            description: 'Presentation in lecture format'
           },
           {id: 2,
            title: 'Workshop',
            length: 60,
            description: 'Interactive hands-on practice'
           }
          ],
        rooms: [],
        tracks: [],
        date_range: 'March 04 - 10',
        revision: 1
      }
    }
  end

  context 'conference does not have rooms and tracks' do
    it 'sets conference attributes with empty room and tracks' do
      expect(serializer.to_json).to eq expected_hash.to_json
    end
  end

  context 'conference has rooms and tracks' do
    before do
      venue = create(:venue, conference: conference)
      _room = create(:room, venue: venue)
      track = create(:track, program: conference.program)

      room_hash = {
        rooms: [{
            id: 1,
            size: 4,
            events: []
          }
        ]
      }
      track_hash = {
        tracks: [{
            id: 1,
            name: track.name,
            description: track.description
          }
        ]
      }

      expected_hash[:conference].merge! room_hash
      expected_hash[:conference].merge! track_hash
    end

    it 'sets conference attributes with rooms and tracks' do
      expect(serializer.to_json).to eq expected_hash.to_json
    end
  end
end
