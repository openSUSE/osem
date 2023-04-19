# frozen_string_literal: true

require 'spec_helper'

describe EventScheduleSerializer, type: :serializer do
  let(:start) { DateTime.new(2000, 1, 2, 3, 4, 5) }
  let(:timezone) { 'Etc/GMT+11' }
  let(:conference) do
    create(:conference, start_date: start.to_date,
                        start_hour: start.hour,
                        timezone:   timezone)
  end
  let(:program) { create(:program, conference: conference) }
  let(:event) { create(:event, program: program) }
  let(:event_schedule) { create(:event_schedule, event: event, start_time: start) }
  let(:serializer) { described_class.new(event_schedule) }

  it 'sets date and room' do
    expected_json = {
      date: '2000-01-02T03:04:05.000-11:00',
      room: event_schedule.room.guid
    }.to_json

    expect(serializer.to_json).to eq expected_json
  end
end
