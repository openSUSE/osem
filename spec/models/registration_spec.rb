require 'spec_helper'

describe 'Registration' do
  subject { create(:registration) }
  let!(:user) { create(:user) }
  let!(:conference) { create(:conference) }
  let!(:registration) { create(:registration, conference: conference, user: user) }

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:registration)).to be_valid
    end

    it { is_expected.to validate_presence_of(:user) }

    it 'validates uniqueness of user in scope of conference' do
      expect(build(:registration, conference: subject.conference, user: subject.user)).not_to be_valid
    end

    describe 'registration_limit_not_exceed' do
      it 'is not valid when limit exceeded' do
        conference.registration_limit = 1
        expect { create(:registration, conference: conference, user: user) }.to raise_error
        expect(user.registrations.size).to be 1
      end
    end
  end

  describe 'association' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:conference) }
    it { is_expected.to have_and_belong_to_many(:events) }
    it { is_expected.to have_and_belong_to_many(:qanswers) }
    it { is_expected.to have_and_belong_to_many(:vchoices) }
    it { is_expected.to have_many(:events_registrations) }
    it { is_expected.to have_many(:events) }
  end

  describe 'after create' do
    after { subject.run_callbacks(:create) }

    # set_week and subscribe_to_conference are private methods
    describe '#set_week' do
      before { subject.created_at = Time.utc(2014, 5, 10) }

      it 'sets week of registration' do
        expect(subject).to receive(:set_week)
        expect(subject.week).to eq 18
      end
    end

    describe '#subscribe_to_conference' do
      it 'subscribes to conference' do
        expect(subject).to receive(:subscribe_to_conference)
        expect(subject.user.subscribed?(subject.conference)).to be true
      end
    end

    it 'sends registrations mail' do
      expect(subject).to receive(:send_registration_mail)
    end
  end

  describe '#week' do
    before { subject.created_at = Date.new(2014, 06, 30) }

    it 'returns week number of created_at' do
      expect(subject.week).to eq(26)
    end
  end

  describe 'registration_to_events_only_if_present' do
    context 'valid' do
      it 'when user registers for events happening while user is at the conference' do
        registration.arrival = conference.start_date
        registration.departure = conference.end_date
        registration.events << create(:event, program: conference.program, start_time: conference.end_date)

        expect(registration.valid?).to eq true
      end
    end

    context 'invalid' do
      it 'when user registers for events happening while user is not at the conference' do
        registration.arrival = conference.start_date
        registration.departure = conference.start_date
        registration.events << create(:event, program: conference.program, start_time: conference.end_date)

        expect(registration.valid?).to eq false
      end
    end
  end
end
