require 'spec_helper'

describe TrackSerializer, type: :serializer do
  let(:track) { create(:track) }
  let(:serializer) { TrackSerializer.new(track) }

  it 'sets guild, name, color' do
    expected_json = {
      track: {
        guid: track.guid,
        name: 'Example Track',
        color: '#ffffff'
      }
    }.to_json

    expect(serializer.to_json).to eq expected_json
  end
end
