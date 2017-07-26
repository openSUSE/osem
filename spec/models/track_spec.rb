require 'spec_helper'

describe Track do
  subject { create(:track) }
  let(:track) { create(:track) }
  let(:self_organized_track) { create(:track, :self_organized) }

  describe 'association' do
    it { is_expected.to belong_to(:program) }
    it { is_expected.to belong_to(:submitter).class_name('User') }
    it { is_expected.to belong_to(:room) }
    it { is_expected.to have_many(:events) }
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
    it { is_expected.to validate_uniqueness_of(:short_name).scoped_to(:program_id) }
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
    end

    context 'when self_organized? returns false' do
      before :each do
        allow(subject).to receive(:self_organized?).and_return(false)
      end

      it { is_expected.to_not validate_presence_of(:relevance) }
    end

    describe '#valid_dates' do
      before :each do
        @conference = create(:conference, start_date: 1.day.ago, end_date: 2.days.from_now)
      end

      context 'is valid' do
        it 'when the track\'s start date is before it\'s end date and between the conference start/end dates' do
          track = build(:track, start_date: Date.today, end_date: Date.tomorrow, program: @conference.program)
          expect(track.valid?).to eq true
        end
      end

      context 'is invalid' do
        it 'when the track\'s start date is before the conference\'s start date' do
          track = build(:track, start_date: 2.days.ago, end_date: Date.tomorrow, program: @conference.program)
          expect(track.valid?).to eq false
          expect(track.errors[:start_date]).to eq ["can't be before the conference start date (#{1.day.ago.to_date})"]
        end

        it 'when the track\'s end date is before the conference\'s start date' do
          track = build(:track, start_date: 3.days.ago, end_date: 2.days.ago, program: @conference.program)
          expect(track.valid?).to eq false
          expect(track.errors[:end_date]).to eq ["can't be before the conference start date (#{1.day.ago.to_date})"]
        end

        it 'when the track\'s start date is after the conference\'s end date' do
          track = build(:track, start_date: 3.days.from_now, end_date: 4.days.from_now, program: @conference.program)
          expect(track.valid?).to eq false
          expect(track.errors[:start_date]).to eq ["can't be after the conference end date (#{2.days.from_now.to_date})"]
        end

        it 'when the track\'s end date is after the conference\'s end date' do
          track = build(:track, start_date: Date.today, end_date: 3.days.from_now, program: @conference.program)
          expect(track.valid?).to eq false
          expect(track.errors[:end_date]).to eq ["can't be after the conference end date (#{2.days.from_now.to_date})"]
        end

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
  end

  describe 'scope' do
    describe '#confirmed' do
      before :each do
        @program = create(:program)
      end

      context 'includes' do
        it 'when track is confirmed' do
          confirmed_track = create(:track, state: 'confirmed', program: @program)
          expect(@program.tracks.confirmed.include?(confirmed_track)).to eq true
        end
      end

      context 'excludes' do
        %w[new to_accept accepted to_reject rejected canceled withdrawn].each do |state|
          it "when track is #{state.humanize}" do
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

    states_transitions = { new: { restart: false, to_accept: true, accept: true, confirm: false, to_reject: true, reject: true, cancel: false, withdraw: true },
                           to_accept: { restart: false, to_accept: false, accept: true, confirm: false, to_reject: false, reject: false, cancel: true, withdraw: true },
                           accepted: { restart: false, to_accept: false, accept: false, confirm: true, to_reject: false, reject: false, cancel: true, withdraw: true },
                           confirmed: { restart: false, to_accept: false, accept: false, confirm: false, to_reject: false, reject: false, cancel: true, withdraw: true },
                           to_reject: { restart: false, to_accept: false, accept: false, confirm: false, to_reject: false, reject: true, cancel: true, withdraw: true },
                           rejected: { restart: true, to_accept: false, accept: false, confirm: false, to_reject: false, reject: false, cancel: false, withdraw: false },
                           canceled: { restart: true, to_accept: false, accept: false, confirm: false, to_reject: false, reject: false, cancel: false, withdraw: false },
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
      expect(@submitter.has_role?(:track_organizer, self_organized_track)).to eq false
      self_organized_track.assign_role_to_submitter
      expect(@submitter.has_role?(:track_organizer, self_organized_track)).to eq true
    end

    it 'is executed when the track is confirmed' do
      self_organized_track.state = 'accepted'
      self_organized_track.save!
      expect(@submitter.has_role?(:track_organizer, self_organized_track)).to eq false
      self_organized_track.confirm
      expect(@submitter.has_role?(:track_organizer, self_organized_track)).to eq true
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
      @an_event_of_the_track = create(:event, program: self_organized_track.program, track: self_organized_track)
    end

    it 'revokes the role of the track organizer' do
      expect(@a_track_organizer.has_role?(:track_organizer, self_organized_track)).to eq true
      self_organized_track.revoke_role_and_cleanup
      expect(@a_track_organizer.has_role?(:track_organizer, self_organized_track)).to eq false
    end

    it 'removes the track from the events that have it set' do
      expect(@an_event_of_the_track.track).to eq self_organized_track
      self_organized_track.revoke_role_and_cleanup
      @an_event_of_the_track.reload
      expect(@an_event_of_the_track.track).to eq nil
    end

    it 'is executed when the track is canceled' do
      self_organized_track.state = 'confirmed'
      self_organized_track.save!
      self_organized_track.cancel
      expect(@a_track_organizer.has_role?(:track_organizer, self_organized_track)).to eq false
      @an_event_of_the_track.reload
      expect(@an_event_of_the_track.track).to eq nil
    end

    it 'is executed when the track is withdrawn' do
      self_organized_track.withdraw
      expect(@a_track_organizer.has_role?(:track_organizer, self_organized_track)).to eq false
      @an_event_of_the_track.reload
      expect(@an_event_of_the_track.track).to eq nil
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
