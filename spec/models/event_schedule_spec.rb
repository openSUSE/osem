require 'spec_helper'

describe EventSchedule do
  let(:conference) { create(:conference) }

  describe 'association' do
    it { should belong_to(:schedule) }
    it { should belong_to(:event) }
    it { should belong_to(:room) }
  end

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:event_schedule)).to be_valid
    end

    it { is_expected.to validate_presence_of(:schedule) }
    it { is_expected.to validate_presence_of(:event) }
    it { is_expected.to validate_presence_of(:room) }
    it { is_expected.to validate_presence_of(:start_time) }

    describe '#start_after_end_hour' do
      context 'is invalid' do
        it 'when event schedule start_time is after the conference end_hour, and returns an error message' do
          new_scheduled_event = build(:event_scheduled, program: conference.program, hour: conference.start_date + conference.end_hour.hours + 1.hour)
          expect(new_scheduled_event.valid?).to eq false
          expect(new_scheduled_event.event_schedules.first.errors[:start_time]).to eq ["can't be after the conference end hour (#{conference.end_hour})"]
        end
      end

      context 'is valid' do
        it 'when event schedule start_time is between the conference end_hour and start_hour' do
          new_scheduled_event = build(:event_scheduled, program: conference.program, hour: conference.start_date + conference.end_hour.hours - 1.hour)
          expect(new_scheduled_event.valid?).to eq true
        end
      end
    end

    describe '#start_before_start_hour' do
      context 'is invalid' do
        it 'when event schedule start_time is before the conference start_hour, and returns an error message' do
          new_scheduled_event = build(:event_scheduled, program: conference.program, hour: conference.start_date)
          expect(new_scheduled_event.valid?).to eq false
          expect(new_scheduled_event.event_schedules.first.errors[:start_time]).to eq ["can't be before the conference start hour (#{conference.start_hour})"]
        end
      end
    end
  end
end
