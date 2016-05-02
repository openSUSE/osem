require 'spec_helper'
describe RoomSerializer, type: :serializer do
  let(:room) { create(:room) }
  let(:serializer) { RoomSerializer.new(room) }

  it 'set guid, name and description' do
    expected_json = {
      room: {
        guid: room.guid,
        name: room.name,
        description: ''
      }
    }.to_json

    expect(serializer.to_json).to eq expected_json
  end
end
