# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                           :bigint           not null, primary key
#  abstract                     :text
#  comments_count               :integer          default(0), not null
#  committee_review             :text
#  description                  :text
#  guid                         :string           not null
#  is_highlight                 :boolean          default(FALSE)
#  language                     :string
#  max_attendees                :integer
#  progress                     :string           default("new"), not null
#  proposal_additional_speakers :text
#  public                       :boolean          default(TRUE)
#  require_registration         :boolean
#  start_time                   :datetime
#  state                        :string           default("new"), not null
#  submission_text              :text
#  subtitle                     :string
#  title                        :string           not null
#  week                         :integer
#  created_at                   :datetime
#  updated_at                   :datetime
#  difficulty_level_id          :integer
#  event_type_id                :integer
#  program_id                   :integer
#  room_id                      :integer
#  track_id                     :integer
#
require 'spec_helper'

describe Event do
  subject { create(:event) }
  let(:conference) { create(:conference) }
  let(:event) { create(:event, program: conference.program) }
  let(:new_event) { create(:event) }
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }

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
        unless (venue = event.program.conference.venue)
          venue = create(:venue, conference: event.program.conference)
        end
        create(:event_schedule, event: event, room: create(:room, venue: venue, size: 3))
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

    describe '#submission_limit' do
      before :each do
        event.event_type.maximum_abstract_length = 3
        event.event_type.minimum_abstract_length = 2
      end

      context 'is valid' do
        it 'when submission text is within limts' do
          event.abstract = 'the magic three'
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

    describe '#valid_track' do
      context 'is valid' do
        it 'when the track belongs to the same program and is confirmed' do
          track = create(:track, state: 'confirmed', program: conference.program)
          event = build(:event, program: conference.program, track: track)
          expect(event.valid?).to eq true
        end
      end

      context 'is invalid' do
        it 'when the track doesn\'t have the same program' do
          track = create(:track, state: 'confirmed')
          event = build(:event, program: conference.program, track: track)
          expect(event.valid?).to eq false
          expect(event.errors[:track]).to eq ['is invalid']
        end

        it 'when the track is unconfirmed' do
          track = create(:track, program: conference.program)
          allow(track).to receive(:confirmed?).and_return(false)
          event = build(:event, program: conference.program, track: track)
          expect(event.valid?).to eq false
          expect(event.errors[:track]).to eq ['is invalid']
        end
      end
    end
  end

  describe '#comments_count' do
    context 'has a valid counter cache' do
      before do
        create(:comment, commentable: event)
      end

      it 'successfully increments comments_count' do
        expected = expect do
          create(:comment, commentable: event)
        end
        expected.to change { event.comments_count }.by(1)
      end

      it 'successfully decrements comments_count' do
        expected = expect do
          event.comment_threads.last.destroy
          event.reload
        end
        expected.to change { event.comments_count }.by(-1)
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
      create(:event_schedule, event: event)
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

  describe '#user_rating' do
    it 'returns 0 if the event has no votes' do
      expect(event.user_rating(user)).to eq 0
    end

    it 'returns 0 if the event has no votes from that user' do
      create(:vote, user: another_user, event: event)
      expect(event.user_rating(user)).to eq 0
    end

    it 'returns the rating if the event has votes from that user' do
      create(:vote, user: another_user, event: event, rating: 3)
      create(:vote, user: user, event: event, rating: 2)
      expect(event.user_rating(user)).to eq 2
    end
  end

  describe '#voted?' do
    it 'returns false if the event has no votes' do
      expect(event.voted?).to eq false
    end

    it 'returns false if the event has no votes by that user' do
      create(:vote, user: another_user, event: event)
      expect(event.voted?(user)).to eq false
    end

    it 'returns true when the event has votes' do
      create(:vote, user: another_user, event: event)
      expect(event.voted?).to eq true
    end

    it 'returns true when the event has votes by that user' do
      create(:vote, user: user, event: event)
      expect(event.voted?(user)).to eq true
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
      submitted_event = create(:event, submitter: submitter)
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

  describe '#transition_possible?(transition)' do
    shared_examples 'transition_possible?(transition)' do |state, transition, expected|
      it "returns #{expected} for #{transition} transition, when the event is #{state}}" do
        my_event = create(:event, state: state)
        expect(my_event.transition_possible?(transition.to_sym)).to eq expected
      end
    end

    states = [:new, :withdrawn, :unconfirmed, :confirmed, :canceled, :rejected]
    transitions = [:restart, :withdraw, :accept, :confirm, :cancel, :reject]

    states_transitions = { new:         { restart: false, withdraw: true, accept: true, confirm: false, cancel: false, reject: true},
                           withdrawn:   { restart: true, withdraw: false, accept: false, confirm: false, cancel: false, reject: false},
                           unconfirmed: { restart: false, withdraw: true, accept: false, confirm: true, cancel: true, reject: false},
                           confirmed:   { restart: false, withdraw: true, accept: false, confirm: false, cancel: true, reject: false},
                           canceled:    { restart: true, withdraw: false, accept: false, confirm: false, cancel: false, reject: false},
                           rejected:    { restart: true, withdraw: false, accept: false, confirm: false, cancel: false, reject: false}
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
        submitter = create(:user, name: 'user speaker 1')

        new_event.submitter = submitter
        new_event.speakers = [submitter]

        expect(new_event.speaker_names).to eq 'user speaker 1'
      end

      it 'when submitter is not a speaker' do
        submitter = create(:user, name: 'user submitter 1')
        speaker1 = create(:user, name: 'user speaker 1')

        new_event.submitter = submitter
        new_event.speakers = [speaker1]

        expect(new_event.speaker_names).to eq 'user speaker 1'
      end

      it 'when there are multiple speakers' do
        submitter = create(:user, name: 'user submitter 1')
        speaker1 = create(:user, name: 'user speaker 1')
        speaker2 = create(:user, name: 'user speaker 2')

        new_event.submitter = submitter
        new_event.speakers = [speaker1, speaker2]

        expect(new_event.speaker_names).to eq 'user speaker 1, user speaker 2'
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

  describe '#selected_schedule_id' do
    before :each do
      conference.program.selected_schedule = create(:schedule, program: conference.program)
    end

    context 'returns the program\'s selected_schedule_id' do
      it 'when it doesn\'t have a track' do
        create(:event_schedule, event: event, schedule: conference.program.selected_schedule)
        expect(event.send(:selected_schedule_id)).to eq conference.program.selected_schedule_id
      end

      it 'when it belongs to a regular track' do
        event.track = create(:track, program: conference.program)
        expect(event.send(:selected_schedule_id)).to eq conference.program.selected_schedule_id
      end
    end

    context 'returns the track\'s selected_schedule_id' do
      it 'when it belongs to a self-organized track' do
        event.track = create(:track, :self_organized, program: conference.program, state: 'confirmed')
        event.track.selected_schedule = create(:schedule, program: conference.program, track: event.track)
        expect(event.send(:selected_schedule_id)).to eq event.track.selected_schedule_id
      end
    end
  end

  describe '#serializable_hash' do
    let(:event2) { create(:event, program: conference.program, abstract: '`markdown`') }

    context 'serializes event correctly' do
      it 'contains rendered markdown in HTML' do
        expect(event2.serializable_hash['rendered_abstract']).to include('<code>markdown</code>')
      end
    end
  end
end
