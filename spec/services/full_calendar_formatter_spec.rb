# frozen_string_literal: true

require 'spec_helper'

describe FullCalendarFormatter do
  let!(:room1) { create(:room) }
  let!(:room2) { create(:room) }

  describe 'JSON formatting for FullCalendar' do
    it 'translates rooms to resources' do
      rooms = [room1, room2]
      resources = described_class.rooms_to_resources(rooms)
      expected_json = [
        {
          id:    room1.guid,
          title: room1.name
        },
        {
          id:    room2.guid,
          title: room2.name
        }
      ].to_json
      expect(resources).to eq(expected_json)
    end
  end
end
