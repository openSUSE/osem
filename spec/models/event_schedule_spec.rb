require 'spec_helper'

describe EventSchedule do
  subject { create(:event_schedule) }
  let(:schedule) { create(:schedule) }
  let(:program) { create(:program, selected_schedule: schedule) }
  let!(:current_event_schedule) { create(:current_event_schedule, schedule: program.selected_schedule) }
  let!(:past_event_schedule) { create(:past_event_schedule) }
  let!(:future_event_schedule) { create(:future_event_schedule) }

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
  end

  describe 'scope' do
    context 'current' do
      it 'returns only current events' do
        expect(program.selected_schedule.event_schedules.current).to match_array([current_event_schedule])
      end
    end
  end
end
