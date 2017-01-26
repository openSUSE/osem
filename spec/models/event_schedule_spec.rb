require 'spec_helper'

describe EventSchedule do

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

    describe '#not_overlapping' do
      let!(:event) { create(:event, event_type: create(:event_type, length: 60)) }
      let!(:event2) { create(:event, event_type: create(:event_type, length: 30), program: event.program) }
      let!(:schedule) { create(:schedule, program: event.program) }
      let!(:room) { create(:room, venue: create(:venue, conference: event.program.conference)) }
      let!(:event_schedule) { create(:event_schedule, schedule: schedule, event: event, room: room, start_time: event.program.conference.start_date.tomorrow.to_time + 60.minutes) }

      describe "can't be scheduled at the same time than other event in the same room" do
        it 'case 1' do
          expect(build(:event_schedule, schedule: schedule, event: event2, room: room, start_time: event_schedule.start_time - 15.minutes)).to_not be_valid
        end

        it 'case 2' do
          expect(build(:event_schedule, schedule: schedule, event: event2, room: room, start_time: event_schedule.start_time + 45.minutes)).to_not be_valid
        end

        it 'case 3' do
          expect(build(:event_schedule, schedule: schedule, event: event2, room: room, start_time: event_schedule.start_time + 15.minutes)).to_not be_valid
        end

        it 'case 4' do
          event2.event_type = create(:event_type, length: 120)
          expect(build(:event_schedule, schedule: schedule, event: event2, room: room, start_time: event_schedule.start_time - 30.minutes)).to_not be_valid
        end
      end
    end
  end
end
