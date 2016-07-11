require 'spec_helper'

describe Event do
  subject { create(:event) }
  let(:conference) { create(:conference) }
  let(:event) { create(:event, program: conference.program) }
  let(:new_event) { create(:event) }
  let(:user) { create(:user) }

  describe 'association' do
    it { is_expected.to belong_to :program }
    it { is_expected.to belong_to :event_type }
    it { is_expected.to have_many :events_registrations }
    it { is_expected.to have_many :registrations }
  end

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:event)).to be_valid
    end

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:abstract) }
    it { is_expected.to validate_presence_of(:program) }
    it { is_expected.to validate_presence_of(:event_type) }

    describe 'max_attendees_no_more_than_room_size' do
      before :each do
        event.room = create(:room, size: 3)
        event.require_registration = true
      end

      it 'it is valid, if max_attendees is less than room size' do
        event.max_attendees = 2

        expect(event.valid?).to eq true
        expect(event.errors.full_messages).to eq []
      end

      it 'it is not valid, if max_attendees attribute is bigger than size of room' do
        event.max_attendees = 4

        expect(event.valid?).to eq false
        expect(event.errors[:max_attendees]).to eq ['cannot be more than the room\'s capacity (3)']
      end
    end

    describe '#abstract_limit' do
      before :each do
        event.event_type.maximum_abstract_length = 2
        event.event_type.minimum_abstract_length = 2
      end

      context 'is invalid' do
        it 'when abstract is too long' do
          event.abstract = 'Test abstract here'
          expect(event.valid?).to eq false
          expect(event.errors[:abstract]).to eq ['cannot have more than 2 words']
        end

        it 'when abstract is too short' do
          event.abstract = 'Test'
          expect(event.valid?).to eq false
          expect(event.errors[:abstract]).to eq ['cannot have less than 2 words']
        end
      end

      context 'is valid' do
        it 'when abstract length is within limits' do
          event.abstract = 'Test abstract'
          expect(event.valid?).to eq true
          expect(event.errors.size).to eq 0
        end
      end
    end

    describe '#before_end_of_conference' do
      context 'is invalid' do
        it 'when event is created after the conference end_date, and returns an error message' do
          conference = create(:conference, start_date: Date.today - 1, end_date: Date.today - 1)
          new_event = build(:event, program: conference.program)
          expect(new_event.valid?).to eq false
          expect(new_event.errors[:created_at]).to eq ["can't be after the conference end date!"]
        end
      end

      context 'is valid' do
        it 'when event is created before the conference end_date' do
          conference = create(:conference, start_date: Date.today - 1, end_date: Date.today + 1)
          new_event = build(:event, program: conference.program)
          expect(new_event.valid?).to eq true
        end
      end
    end
  end

  describe 'scope ' do
    context 'confirmed' do
      it 'returns only confirmed events' do
        my_event = create(:event, state: 'confirmed', program: conference.program)

        expect(conference.program.events.confirmed).to eq [my_event]
      end
    end

    context 'highlighted' do
      it 'returns only highlighted events' do
        my_event = create(:event, is_highlight: true, program: conference.program)

        expect(conference.program.events.highlighted).to eq [my_event]
      end
    end
  end

  describe '#scheduled?' do
    it { expect(event.scheduled?).to eq false }
    it 'returns true if the event is scheduled' do
      event.room = create(:room)
      event.start_time = conference.start_date.to_time
      expect(event.scheduled?).to eq true
    end
  end

  describe '#registration_possible?' do
    describe 'when the event requires registration' do
      before :each do
        event.state = 'confirmed'
        event.require_registration = true
        event.max_attendees = 3
        event.registrations << create(:registration)
        event.save!
      end

      it 'returns true, if the event has no max_attendees' do
        event.max_attendees = nil
        event.save!
        expect(event.registration_possible?).to eq true
      end

      it 'returns true, if the limit has not been reached' do
        expect(event.registration_possible?).to eq true
      end

      it 'returns true, if the event is confirmed' do
        event.save!
        expect(event.registration_possible?).to eq true
      end

      it 'returns false, if the limit has been reached' do
        event.registrations << create(:registration)
        event.registrations << create(:registration)
        expect(event.registration_possible?).to eq false
      end

      it 'returns false, if the event is not confirmed' do
        event.state = 'new'
        event.save!
        expect(event.registration_possible?).to eq false
      end
    end

    describe 'when the event does not require registration' do
      it 'returns false' do
        expect(event.registration_possible?).to eq false
      end
    end
  end

  describe '#voted?' do
    it 'returns nil if the event has no votes' do
      expect(event.voted?(event, user)).to eq nil
    end

    it 'returns the first vote when the event has votes' do
      vote = create(:vote, user: user, event: event)
      expect(event.voted?(event, user)).to eq vote
    end
  end

  describe '#average_rating' do
    context 'returns 0' do
      it 'when there are no votes' do
        expect(event.average_rating).to eq 0
      end
    end

    context 'returns the average voting' do
      before :each do
        another_user = create(:user)
        create(:vote, user: user, event: event, rating: 1)
        create(:vote, user: another_user, event: event, rating: 3)
      end

      it 'when there are votes and the average is integer' do
        expect(event.average_rating).to eq '2'
      end

      it 'when there are votes and the average is float' do
        new_user = create(:user)
        create(:vote, user: new_user, event: event, rating: 3)
        expect(event.average_rating).to eq '2.33'
      end
    end
  end

  describe '#submitter' do
    it 'returns the user that submitted the event' do
      submitter = create(:user)
      submitted_event = create(:event)
      submitted_event.event_users = [create(:event_user, user: submitter, event_role: 'submitter')]

      expect(submitted_event.submitter).to eq submitter
    end
  end

  describe '#abstract_word_count' do
    it 'counts words in abstract' do
      event = build(:event)
      expect(event.abstract_word_count).to eq(event.abstract.to_s.split.size)
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

  describe '#as_json' do
    it 'adds the event\'s room_guid, track_color and length' do
      event.room = create(:room)
      event.track = create(:track, color: '#efefef')
      json_hash = event.as_json(nil)

      expect(json_hash[:room_guid]).to eq(event.room.guid)
      expect(json_hash[:track_color]).to eq('#EFEFEF')
      expect(json_hash[:length]).to eq(30)
    end

    it 'uses correct default values for room_guid, track_color and length' do
      event.event_type = nil
      json_hash = event.as_json(nil)

      expect(json_hash[:room_guid]).to be_nil
      expect(json_hash[:track_color]).to eq('#FFFFFF')
      expect(json_hash[:length]).to eq(25)
    end
  end

  describe '#transition_possible?(transition)' do
    shared_examples 'transition_possible?(transition)' do |state, transition, expected|
      it "returns #{expected} for #{transition} transition, when the event is #{state}}" do
        my_event = create(:event, state: state)
        expect(my_event.transition_possible?(transition.to_sym)).to eq expected
      end
    end

    states = [:new, :withdrawn, :unconfirmed, :confirmed, :canceled, :rejected]
    transitions = [:restart, :withdraw, :accept, :confirm, :cancel, :reject]

    states_transitions = { new: { restart: false, withdraw: true, accept: true, confirm: false, cancel: false, reject: true},
                           withdrawn: { restart: true, withdraw: false, accept: false, confirm: false, cancel: false, reject: false},
                           unconfirmed: { restart: false, withdraw: true, accept: false, confirm: true, cancel: true, reject: false},
                           confirmed: { restart: false, withdraw: true, accept: false, confirm: false, cancel: true, reject: false},
                           canceled: { restart: true, withdraw: false, accept: false, confirm: false, cancel: false, reject: false},
                           rejected: { restart: true, withdraw: false, accept: false, confirm: false, cancel: false, reject: false}
                         }

    states.each do |state|
      transitions.each do |transition|
        it_behaves_like 'transition_possible?(transition)', state, transition, states_transitions[state.to_sym][transition.to_sym]
      end
    end
  end

  describe '#speaker_names' do
    context 'returns the speakers of the event' do
      it 'when submitter is a speaker too' do
        speaker1 = create(:user, name: 'user speaker 1')
        new_event.event_users = [create(:event_user, user: speaker1, event_role: 'submitter')]
        new_event.event_users << [create(:event_user, user: speaker1, event_role: 'speaker')]

        expect(new_event.speaker_names).to eq 'user speaker 1'
      end

      it 'when submitter is not a speaker' do
        submitter = create(:user, name: 'user submitter 1')
        speaker1 = create(:user, name: 'user speaker 1')

        new_event.event_users = [create(:event_user, user: submitter, event_role: 'submitter')]
        new_event.event_users << [create(:event_user, user: speaker1, event_role: 'speaker')]

        expect(new_event.speaker_names).to eq 'user submitter 1 and user speaker 1'
      end

      it 'when there are multiple speakers' do
        submitter = create(:user, name: 'user submitter 1')
        speaker1 = create(:user, name: 'user speaker 1')
        speaker2 = create(:user, name: 'user speaker 2')

        new_event.event_users = [create(:event_user, user: submitter, event_role: 'submitter')]
        new_event.event_users << [create(:event_user, user: speaker1, event_role: 'speaker')]
        new_event.event_users << [create(:event_user, user: speaker2, event_role: 'speaker')]

        expect(new_event.speaker_names).to eq 'user submitter 1, user speaker 1, and user speaker 2'
      end
    end
  end

  describe '#set_week' do
    it 'sets correct week number' do
      conference = create(:conference, start_date: Date.new(2015, 12, 1), end_date: Date.new(2015, 12, 1))
      other_event = create(:event, created_at: Date.new(2015, 12, 1), program: conference.program)

      expect(other_event.week).to eq 48
    end
  end
end
