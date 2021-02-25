# frozen_string_literal: true

# == Schema Information
#
# Table name: tracks
#
#  id                   :bigint           not null, primary key
#  cfp_active           :boolean          not null
#  color                :string
#  description          :text
#  end_date             :date
#  guid                 :string           not null
#  name                 :string           not null
#  relevance            :text
#  short_name           :string           not null
#  start_date           :date
#  state                :string           default("new"), not null
#  created_at           :datetime
#  updated_at           :datetime
#  program_id           :integer
#  room_id              :integer
#  selected_schedule_id :integer
#  submitter_id         :integer
#
# Indexes
#
#  index_tracks_on_room_id               (room_id)
#  index_tracks_on_selected_schedule_id  (selected_schedule_id)
#  index_tracks_on_submitter_id          (submitter_id)
#
require 'spec_helper'

describe Track do
  subject { create(:track) }
  let(:track) { create(:track) }
  let(:self_organized_track) { create(:track, :self_organized) }

  describe 'association' do
    it { is_expected.to belong_to(:program) }
    it { is_expected.to belong_to(:submitter).class_name('User') }
    it { is_expected.to belong_to(:room) }
    it { is_expected.to belong_to(:selected_schedule).class_name('Schedule') }
    it { is_expected.to have_many(:events) }
    it { is_expected.to have_many(:schedules) }
  end

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:track)).to be_valid
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to allow_value('#ABCDEF').for(:color) }
    it { is_expected.to allow_value('#124689').for(:color) }
    it { is_expected.to validate_presence_of(:short_name) }
    it { is_expected.to allow_value('My_track_name').for(:short_name) }
    it { is_expected.to_not allow_value('My track name').for(:short_name) }
    # there is a bug: https://github.com/thoughtbot/shoulda-matchers/issues/814
    # it { is_expected.to validate_uniqueness_of(:short_name).ignoring_case_sensitivity.scoped_to(:program) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_inclusion_of(:state).in_array(%w[new to_accept accepted confirmed to_reject rejected canceled withdrawn]) }
    it { is_expected.to validate_inclusion_of(:cfp_active).in_array([true, false]) }

    context 'when self_organized_and_accepted_or_confirmed? returns true' do
      before :each do
        allow(subject).to receive(:self_organized_and_accepted_or_confirmed?).and_return(true)
      end

      it { is_expected.to validate_presence_of(:start_date) }
      it { is_expected.to validate_presence_of(:end_date) }
      it { is_expected.to validate_presence_of(:room) }
    end

    context 'when self_organized_and_accepted_or_confirmed? returns false' do
      before :each do
        allow(subject).to receive(:self_organized_and_accepted_or_confirmed?).and_return(false)
      end

      it { is_expected.to_not validate_presence_of(:start_date) }
      it { is_expected.to_not validate_presence_of(:end_date) }
      it { is_expected.to_not validate_presence_of(:room) }
    end

    context 'when self_organized? returns true' do
      before :each do
        allow(subject).to receive(:self_organized?).and_return(true)
      end

      it { is_expected.to validate_presence_of(:relevance) }
      it { is_expected.to validate_presence_of(:description) }
    end

    context 'when self_organized? returns false' do
      before :each do
        allow(subject).to receive(:self_organized?).and_return(false)
      end

      it { is_expected.to_not validate_presence_of(:relevance) }
      it { is_expected.to_not validate_presence_of(:description) }
    end

    describe '#dates_within_conference_dates' do
      before :each do
        @conference = create(:conference, start_date: 1.day.ago, end_date: 2.days.from_now)
      end

      context 'is valid' do
        it 'when the track\'s dates are between the conference\'s dates' do
          track = build(:track, start_date: @conference.start_date, end_date: @conference.end_date, program: @conference.program)
          expect(track.valid?).to eq true
        end
      end

      context 'is invalid' do
        it 'when the track\'s start date is before the conference\'s start date' do
          track = build(:track, start_date: 2.days.ago, end_date: Date.tomorrow, program: @conference.program)
          expect(track.valid?).to eq false
          expect(track.errors[:start_date]).to eq ["can't be outside of the conference's dates (#{1.day.ago.to_date}-#{2.days.from_now.to_date})"]
        end

        it 'when the track\'s start date is after the conference\'s end date' do
          track = build(:track, start_date: 3.days.from_now, end_date: 4.days.from_now, program: @conference.program)
          expect(track.valid?).to eq false
          expect(track.errors[:start_date]).to eq ["can't be outside of the conference's dates (#{1.day.ago.to_date}-#{2.days.from_now.to_date})"]
        end

        it 'when the track\'s end date is before the conference\'s start date' do
          track = build(:track, start_date: 3.days.ago, end_date: 2.days.ago, program: @conference.program)
          expect(track.valid?).to eq false
          expect(track.errors[:end_date]).to eq ["can't be outside of the conference's dates (#{1.day.ago.to_date}-#{2.days.from_now.to_date})"]
        end

        it 'when the track\'s end date is after the conference\'s end date' do
          track = build(:track, start_date: Date.today, end_date: 3.days.from_now, program: @conference.program)
          expect(track.valid?).to eq false
          expect(track.errors[:end_date]).to eq ["can't be outside of the conference's dates (#{1.day.ago.to_date}-#{2.days.from_now.to_date})"]
        end
      end
    end

    describe '#start_date_before_end_date' do
      before :each do
        @conference = create(:conference, start_date: 1.day.ago, end_date: 2.days.from_now)
      end

      context 'is valid' do
        it 'when the track\'s start date is before its end date' do
          track = build(:track, start_date: Date.today, end_date: Date.tomorrow, program: @conference.program)
          expect(track.valid?).to eq true
        end
      end

      context 'is invalid' do
        it 'when the track\'s start date is after it\'s end date' do
          track = build(:track, start_date: 1.day.from_now, end_date: 1.day.ago)
          expect(track.valid?).to eq false
          expect(track.errors[:start_date]).to eq ['can\'t be after the end date']
        end
      end
    end

    describe '#valid_room' do
      before :each do
        @conference = create(:conference)
        @conference.venue = create(:venue, name: 'The venue')
      end

      context 'is valid' do
        it 'when the track\'s room belongs to the venue of the conference' do
          room = create(:room, venue: @conference.venue)
          track = build(:track, :self_organized, state: 'accepted', program: @conference.program, room: room)
          expect(track.valid?).to eq true
        end
      end

      context 'is invalid' do
        it 'when the track\'s room doesn\'t belong to the venue of the track\'s conference' do
          other_conference = create(:conference)
          other_conference.venue = create(:venue)
          room = create(:room, venue: other_conference.venue)
          track = build(:track, :self_organized, state: 'accepted', program: @conference.program, room: room)
          expect(track.valid?).to eq false
          expect(track.errors[:room]).to eq ['must be a room of The venue']
        end
      end
    end

    describe '#overlapping' do
      before :each do
        @conference = create(:conference, start_date: Date.current - 1.day, end_date: Date.current + 2.days)
        @conference.venue = create(:venue)
        @room = create(:room, venue: @conference.venue)
      end

      context 'is valid' do
        it 'when the tracks are in different rooms at the same time' do
          other_room = create(:room, venue: @conference.venue)
          create(:track, :self_organized, state: 'confirmed', program: @conference.program, room: other_room, start_date: Date.current, end_date: Date.current)
          track = build(:track, :self_organized, program: @conference.program, room: @room, start_date: Date.current, end_date: Date.current)
          expect(track.valid?).to eq true
        end

        it 'when it ends before the other tracks in the same room' do
          create(:track, :self_organized, state: 'confirmed', program: @conference.program, room: @room, start_date: Date.current, end_date: Date.current)
          track = build(:track, :self_organized, program: @conference.program, room: @room, start_date: Date.current - 1.day, end_date: Date.current - 1.day)
          expect(track.valid?).to eq true
        end

        it 'when it starts after the other tracks in the same room' do
          create(:track, :self_organized, state: 'confirmed', program: @conference.program, room: @room, start_date: Date.current, end_date: Date.current)
          track = build(:track, :self_organized, program: @conference.program, room: @room, start_date: Date.current + 1.day, end_date: Date.current + 1.day)
          expect(track.valid?).to eq true
        end
      end

      context 'is invalid' do
        it 'when it starts and/or ends with another track in the same room' do
          create(:track, :self_organized, state: 'confirmed', program: @conference.program, room: @room, start_date: Date.current, end_date: Date.current)
          track = build(:track, :self_organized, program: @conference.program, room: @room, start_date: Date.current, end_date: Date.current)
          expect(track.valid?).to eq false
          expect(track.errors[:track]).to eq ['has overlapping dates with a confirmed or accepted track in the same room']
        end

        it 'when it starts before another track and ends after the other starts and before it ends' do
          create(:track, :self_organized, state: 'confirmed', program: @conference.program, room: @room, start_date: Date.current, end_date: Date.current + 2.days)
          track = build(:track, :self_organized, program: @conference.program, room: @room, start_date: Date.current - 1.day, end_date: Date.current + 1.day)
          expect(track.valid?).to eq false
          expect(track.errors[:track]).to eq ['has overlapping dates with a confirmed or accepted track in the same room']
        end

        it 'when it starts after another track and before it ends and ends after the other' do
          create(:track, :self_organized, state: 'confirmed', program: @conference.program, room: @room, start_date: Date.current, end_date: Date.current + 2.days)
          track = build(:track, :self_organized, program: @conference.program, room: @room, start_date: Date.current + 1.day, end_date: Date.current + 3.days)
          expect(track.valid?).to eq false
          expect(track.errors[:track]).to eq ['has overlapping dates with a confirmed or accepted track in the same room']
        end

        it 'when it starts after another track and ends before the other' do
          create(:track, :self_organized, state: 'confirmed', program: @conference.program, room: @room, start_date: Date.current, end_date: Date.current + 2.days)
          track = build(:track, :self_organized, program: @conference.program, room: @room, start_date: Date.current + 1.day, end_date: Date.current + 1.day)
          expect(track.valid?).to eq false
          expect(track.errors[:track]).to eq ['has overlapping dates with a confirmed or accepted track in the same room']
        end

        it 'when it starts before another track and ends after the other' do
          create(:track, :self_organized, state: 'confirmed', program: @conference.program, room: @room, start_date: Date.current, end_date: Date.current)
          track = build(:track, :self_organized, program: @conference.program, room: @room, start_date: Date.current - 1.day, end_date: Date.current + 1.day)
          expect(track.valid?).to eq false
          expect(track.errors[:track]).to eq ['has overlapping dates with a confirmed or accepted track in the same room']
        end
      end
    end
  end

  describe 'scope' do
    describe '#accepted' do
      before :each do
        @program = create(:program)
      end

      context 'includes' do
        it 'when track is accepted' do
          accepted_track = create(:track, state: 'accepted', program: @program)
          expect(@program.tracks.accepted.include?(accepted_track)).to eq true
        end
      end

      context 'excludes' do
        %w[new to_accept confirmed to_reject rejected canceled withdrawn].each do |state|
          it "when track is #{state.humanize}" do
            not_accepted_track = create(:track, state: state, program: @program)
            expect(@program.tracks.accepted.include?(not_accepted_track)).to eq false
          end
        end
      end
    end

    describe '#confirmed' do
      before :each do
        @program = create(:program)
      end

      context 'includes' do
        it 'tracks with state \'confirmed\'' do
          confirmed_track = create(:track, state: 'confirmed', program: @program)
          expect(@program.tracks.confirmed.include?(confirmed_track)).to eq true
        end
      end

      context 'excludes' do
        %w[new to_accept accepted to_reject rejected canceled withdrawn].each do |state|
          it "tracks with state '#{state}'" do
            unconfirmed_track = create(:track, state: state, program: @program)
            expect(@program.tracks.confirmed.include?(unconfirmed_track)).to eq false
          end
        end
      end
    end

    describe '#cfp_active' do
      before :each do
        @program = create(:program)
        @cfp_active_track = create(:track, cfp_active: true, program: @program)
        @non_cfp_active_track = create(:track, cfp_active: false, program: @program)
      end

      it 'include tracks with the cfp_active flag enabled' do
        expect(@program.tracks.cfp_active.include?(@cfp_active_track)).to eq true
      end

      it 'excludes tracks with the cfp_active flag disabled' do
        expect(@program.tracks.cfp_active.include?(@non_cfp_active_track)).to eq false
      end
    end

    describe '#self_organized' do
      before :each do
        @program = create(:program)
        track.program = @program
        track.save!
        self_organized_track.program = @program
        self_organized_track.save!
      end

      it 'includes self-organized tracks' do
        expect(@program.tracks.self_organized.include?(self_organized_track)).to eq true
      end

      it 'excludes regular tracks' do
        expect(@program.tracks.self_organized.include?(track)).to eq false
      end
    end
  end

  describe '#self_organized?' do
    it 'returns true when it has a submitter' do
      expect(self_organized_track.submitter).to be_a User
      expect(self_organized_track.self_organized?).to eq true
    end

    it 'returns false when it doesn\'t have a submitter' do
      expect(track.submitter).to eq nil
      expect(track.self_organized?).to eq false
    end
  end

  describe '#transition_possible?' do
    shared_examples 'transition_possible?' do |state, transition, expected|
      it "returns #{expected} for #{transition} event, when the track's state is #{state}}" do
        my_self_organized_track = create(:track, :self_organized, state: state)
        expect(my_self_organized_track.transition_possible?(transition.to_sym)).to eq expected
      end
    end

    states = [:new, :to_accept, :accepted, :confirmed, :to_reject, :rejected, :canceled, :withdrawn]
    transitions = [:restart, :to_accept, :accept, :confirm, :to_reject, :reject, :cancel, :withdraw]

    states_transitions = { new:       { restart: false, to_accept: true, accept: true, confirm: false, to_reject: true, reject: true, cancel: false, withdraw: true },
                           to_accept: { restart: false, to_accept: false, accept: true, confirm: false, to_reject: true, reject: false, cancel: true, withdraw: true },
                           accepted:  { restart: false, to_accept: false, accept: false, confirm: true, to_reject: false, reject: false, cancel: true, withdraw: true },
                           confirmed: { restart: false, to_accept: false, accept: false, confirm: false, to_reject: false, reject: false, cancel: true, withdraw: true },
                           to_reject: { restart: false, to_accept: true, accept: false, confirm: false, to_reject: false, reject: true, cancel: true, withdraw: true },
                           rejected:  { restart: true, to_accept: false, accept: false, confirm: false, to_reject: false, reject: false, cancel: false, withdraw: false },
                           canceled:  { restart: true, to_accept: false, accept: false, confirm: false, to_reject: false, reject: false, cancel: false, withdraw: false },
                           withdrawn: { restart: true, to_accept: false, accept: false, confirm: false, to_reject: false, reject: false, cancel: false, withdraw: false } }

    states.each do |state|
      transitions.each do |transition|
        it_behaves_like 'transition_possible?', state, transition, states_transitions[state.to_sym][transition.to_sym]
      end
    end
  end

  describe '#assign_role_to_submitter' do
    before :each do
      Role.where(name: 'track_organizer', resource: self_organized_track).first_or_create
      @submitter = self_organized_track.submitter
    end

    it 'gives the role of the track organizer to the submitter of the track' do
      expect(@submitter.has_cached_role?(:track_organizer, self_organized_track)).to eq false
      self_organized_track.assign_role_to_submitter
      expect(@submitter.has_cached_role?(:track_organizer, self_organized_track)).to eq true
    end

    it 'is executed when the track is confirmed' do
      self_organized_track.state = 'accepted'
      self_organized_track.save!
      expect(@submitter.has_cached_role?(:track_organizer, self_organized_track)).to eq false
      self_organized_track.confirm
      expect(@submitter.has_cached_role?(:track_organizer, self_organized_track)).to eq true
    end
  end

  describe '#revoke_role_and_cleanup' do
    before :each do
      Role.where(name: 'track_organizer', resource: self_organized_track).first_or_create
      @a_track_organizer = create(:user)
      self_organized_track.state = 'confirmed'
      self_organized_track.cfp_active = true
      self_organized_track.save!
      @a_track_organizer.add_role 'track_organizer', self_organized_track
      @event_of_self_organized_track = create(:event, program: self_organized_track.program, track: self_organized_track, state: 'confirmed')
      @schedule_of_self_organized_track = create(:schedule, program: self_organized_track.program, track: self_organized_track)
    end

    it 'revokes the role of the track organizer' do
      expect(@a_track_organizer.has_cached_role?(:track_organizer, self_organized_track)).to eq true
      self_organized_track.revoke_role_and_cleanup
      @a_track_organizer.reload
      expect(@a_track_organizer.has_cached_role?(:track_organizer, self_organized_track)).to eq false
    end

    it 'destroys the track\'s schedules' do
      expect(Schedule.find(@schedule_of_self_organized_track.id)).to eq @schedule_of_self_organized_track
      self_organized_track.revoke_role_and_cleanup
      expect(Schedule.find_by(id: @schedule_of_self_organized_track.id)).to eq nil
    end

    it 'removes the track from the events that have it set' do
      expect(@event_of_self_organized_track.track).to eq self_organized_track
      self_organized_track.revoke_role_and_cleanup
      @event_of_self_organized_track.reload
      expect(@event_of_self_organized_track.track).to eq nil
    end

    it 'sets the state of the track\'s events to new' do
      expect(@event_of_self_organized_track.state).to eq 'confirmed'
      self_organized_track.revoke_role_and_cleanup
      @event_of_self_organized_track.reload
      expect(@event_of_self_organized_track.state).to eq 'new'
    end

    it 'is executed when the track is canceled' do
      self_organized_track.state = 'confirmed'
      self_organized_track.save!
      self_organized_track.cancel
      @a_track_organizer.reload
      expect(@a_track_organizer.has_cached_role?(:track_organizer, self_organized_track)).to eq false
      @event_of_self_organized_track.reload
      expect(@event_of_self_organized_track.track).to eq nil
    end

    it 'is executed when the track is withdrawn' do
      self_organized_track.withdraw
      @a_track_organizer.reload
      expect(@a_track_organizer.has_cached_role?(:track_organizer, self_organized_track)).to eq false
      @event_of_self_organized_track.reload
      expect(@event_of_self_organized_track.track).to eq nil
    end
  end

  describe '#accepted?' do
    context 'returns true' do
      it 'when the state is "accepted"' do
        self_organized_track.state = 'accepted'
        self_organized_track.save!
        expect(self_organized_track.accepted?).to eq true
      end
    end

    context 'returns false' do
      %w[new to_accept confirmed to_reject rejected canceled withdrawn].each do |state|
        it "when the state is \"#{state}\"" do
          self_organized_track.state = state
          self_organized_track.save!
          expect(self_organized_track.accepted?).to eq false
        end
      end
    end
  end

  describe '#confirmed?' do
    context 'returns true' do
      it 'when the state is "confirmed"' do
        self_organized_track.state = 'confirmed'
        self_organized_track.save!
        expect(self_organized_track.confirmed?).to eq true
      end
    end

    context 'returns false' do
      %w[new to_accept accepted to_reject rejected canceled withdrawn].each do |state|
        it "when the state is \"#{state}\"" do
          self_organized_track.state = state
          self_organized_track.save!
          expect(self_organized_track.confirmed?).to eq false
        end
      end
    end
  end

  # accepted? and confirmed? are mutually exclusive (they can't be both true)
  describe '#self_organized_and_accepted_or_confirmed?' do
    context 'returns true' do
      context 'when self_organized? returns true' do
        before :each do
          allow(track).to receive(:self_organized?).and_return(true)
        end

        context 'accepted? returns true and confirmed? returns false' do
          before :each do
            allow(track).to receive(:accepted?).and_return(true)
            allow(track).to receive(:confirmed?).and_return(false)
          end

          it { expect(track.self_organized_and_accepted_or_confirmed?).to eq true }
        end

        context 'accepted? returns false and confirmed? returns true' do
          before :each do
            allow(track).to receive(:accepted?).and_return(false)
            allow(track).to receive(:confirmed?).and_return(true)
          end

          it { expect(track.self_organized_and_accepted_or_confirmed?).to eq true }
        end
      end
    end

    context 'returns false' do
      context 'when self_organized? returns true' do
        before :each do
          allow(track).to receive(:self_organized?).and_return(true)
        end

        context 'accepted? returns false and confirmed? returns false' do
          before :each do
            allow(track).to receive(:accepted?).and_return(false)
            allow(track).to receive(:confirmed?).and_return(false)
          end

          it { expect(track.self_organized_and_accepted_or_confirmed?).to eq false }
        end
      end

      context 'when self_organized? returns false' do
        before :each do
          allow(track).to receive(:self_organized?).and_return(false)
        end

        context 'accepted? returns false and confirmed? returns false' do
          before :each do
            allow(track).to receive(:accepted?).and_return(false)
            allow(track).to receive(:confirmed?).and_return(false)
          end

          it { expect(track.self_organized_and_accepted_or_confirmed?).to eq false }
        end

        context 'accepted? returns true and confirmed? returns false' do
          before :each do
            allow(track).to receive(:accepted?).and_return(true)
            allow(track).to receive(:confirmed?).and_return(false)
          end

          it { expect(track.self_organized_and_accepted_or_confirmed?).to eq false }
        end

        context 'accepted? returns false and confirmed? returns true' do
          before :each do
            allow(track).to receive(:accepted?).and_return(false)
            allow(track).to receive(:confirmed?).and_return(true)
          end

          it { expect(track.self_organized_and_accepted_or_confirmed?).to eq false }
        end
      end
    end
  end

  describe '#create_organizer_role' do
    it 'creates the role of the track organizer' do
      expect(Role.find_by(name: 'track_organizer', resource: self_organized_track)).to eq nil
      self_organized_track.send(:create_organizer_role)
      expect(Role.find_by(name: 'track_organizer', resource: self_organized_track).description).to eq 'For the organizers of the Track'
    end

    it 'is executed when the track is accepted' do
      expect(Role.find_by(name: 'track_organizer', resource: self_organized_track)).to eq nil
      self_organized_track.accept
      expect(Role.find_by(name: 'track_organizer', resource: self_organized_track).description).to eq 'For the organizers of the Track'
    end
  end
end
