require 'spec_helper'

describe 'Booth' do
  subject { create(:booth) }
  let!(:conference) { create(:conference) }

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:booth)).to be_valid
    end

    it { is_expected.to validate_presence_of(:reasoning) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:responsibles) }
    it { is_expected.to validate_presence_of(:submitter_relationship) }
    it { is_expected.to validate_presence_of(:website_url) }

    it 'is not valid without a title' do
      is_expected.to validate_presence_of(:title)
    end
  end

  describe 'association' do
    it { is_expected.to belong_to(:conference) }
    it { is_expected.to have_many(:booth_requests) }
  end

  describe '#transition_possible?(transition)' do
    shared_examples 'transition_possible?(transition)' do |state, transition, expected|
      it "returns #{expected} for #{transition} transition, when the booth is #{state}}" do
        my_booth = create(:booth, state: state)
        expect(my_booth.transition_possible?(transition.to_sym)).to eq expected
      end
    end

    states = [:new, :withdrawn, :to_accept, :accepted, :to_reject, :rejected, :canceled]
    transitions = [:restart, :withdraw, :accept, :reject, :to_accept, :to_reject, :cancel]

    states_transitions = { new: { restart: false, withdraw: true, accept: true, to_accept: true, to_reject: true, reject: true, cancel: false },
                           withdrawn: { restart: true, withdraw: false, accept: false, to_accept: false, to_reject: false, reject: false, cancel: false },
                           to_accept: { restart: true, withdraw: true, accept: true, to_accept: false, to_reject: true, reject: false, cancel: true },
                           to_reject: { restart: true, withdraw: true, accept: false, to_accept: true, to_reject: false, reject: true, cancel: true },
                           accepted: { restart: false, withdraw: true, accept: false, to_accept: false, to_reject: false, reject: false, cancel: true },
                           rejected: { restart: false, withdraw: true, accept: false, to_accept: false, to_reject: false, reject: false, cancel: true },
                           canceled: { restart: true, withdraw: false, accept: false, to_accept: false, to_reject: false, reject: false, cancel: false } }

    states.each do |state|
      transitions.each do |transition|
        it_behaves_like 'transition_possible?(transition)', state, transition, states_transitions[state.to_sym][transition.to_sym]
      end
    end
  end

end
