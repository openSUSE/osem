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

    describe '#same_room_as_track' do
      before :each do
        conference = create(:conference)
        conference.venue = create(:venue)
        @room = create(:room, venue: conference.venue)
        @track = create(:track, program: conference.program, room: @room)
        @event = create(:event, program: conference.program, track: @track)
      end

      context 'is valid' do
        it 'when scheduled in the track\'s room' do
          event_schedule = build(:event_schedule, event: @event, room: @room)
          expect(event_schedule.valid?).to eq true
        end

        it 'when the track doesn\'t have a room' do
          @track.room = nil
          @track.save!
          event_schedule = build(:event_schedule, event: @event)
          expect(event_schedule.valid?).to eq true
        end
      end

      context 'is invalid' do
        it 'when scheduled in different room than the track\'s' do
          event_schedule = build(:event_schedule, event: @event)
          expect(event_schedule.valid?).to eq false
          expect(event_schedule.errors[:room]).to eq ["must be the same as the track's room (#{@room.name})"]
        end
      end
    end

    describe '#during_track' do
      before :each do
        conference = create(:conference, start_date: Date.current - 1.day, start_hour: 0, end_hour: 24)
        conference.venue = create(:venue)
        @room = create(:room, venue: conference.venue)
        @track = create(:track, program: conference.program, room: @room, start_date: Date.current, end_date: Date.current)
        @event = create(:event, program: conference.program, track: @track)
      end

      context 'is valid' do
        it 'when scheduled during the track\'s time slot' do
          event_schedule = build(:event_schedule, event: @event, room: @room, start_time: Date.current + 3.hours)
          expect(event_schedule.valid?).to eq true
        end
      end

      context 'is invalid' do
        it 'when scheduled before the track\'s start date' do
          event_schedule = build(:event_schedule, event: @event, room: @room, start_time: Date.current - 1.hour)
          expect(event_schedule.valid?).to eq false
          expect(event_schedule.errors[:start_time]).to eq ["can't be before the track's start date (#{@track.start_date})"]
        end

        it 'when event ends after the track\'s end date' do
          event_schedule = build(:event_schedule, event: @event, room: @room, start_time: Date.current + 1.day - 10.minutes)
          expect(event_schedule.valid?).to eq false
          expect(event_schedule.errors[:end_time]).to eq ["can't be after the track's end date (#{@track.end_date})"]
        end
      end
    end

    describe '#valid_schedule' do
      before :each do
        conference.venue = create(:venue)
        @room = create(:room, venue: conference.venue)
        track = create(:track, :self_organized, program: conference.program, room: @room, state: 'confirmed', name: 'My awesome track')
        @event = create(:event, program: conference.program, track: track)
      end

      context 'is valid' do
        it 'when the event belongs to a self-organized track and is scheduled in one of its track\'s schedules' do
          schedule = create(:schedule, program: conference.program, track: @event.track)
          event_schedule = build(:event_schedule, event: @event, room: @room, schedule: schedule)
          expect(event_schedule.valid?).to eq true
          expect(event_schedule.errors[:schedule]).to eq []
        end

        it 'when the event doesn\'t belong to a self-organized track' do
          @event.track = nil
          @event.save!
          event_schedule = build(:event_schedule, event: @event, room: @room)
          expect(event_schedule.valid?).to eq true
          expect(event_schedule.errors[:schedule]).to eq []
        end
      end

      context 'is invalid' do
        it 'when the event belongs to a self_organized track but isn\'t scheduled in one of its schedules' do
          event_schedule = build(:event_schedule, event: @event, room: @room)
          expect(event_schedule.valid?).to eq false
          expect(event_schedule.errors[:schedule]).to eq ['must be one of My awesome track track\'s schedules']
        end
      end
    end
  end
end
