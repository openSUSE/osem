require 'spec_helper'

describe Track do
  subject { create(:track) }
  let(:track) { create(:track) }
  let(:self_organized_track) { create(:track, :self_organized) }

  describe 'association' do
    it { is_expected.to belong_to(:program) }
    it { is_expected.to belong_to(:submitter).class_name('User') }
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

    context 'when self-organized' do
      before :each do
        allow(subject).to receive(:self_organized?).and_return(true)
      end

      it { is_expected.to validate_presence_of(:state) }
      it { is_expected.to validate_inclusion_of(:cfp_active).in_array([true, false]) }
    end

    context 'when regular' do
      before :each do
        allow(subject).to receive(:self_organized?).and_return(false)
      end

      it { is_expected.to_not validate_presence_of(:state) }
      it { is_expected.to_not validate_inclusion_of(:cfp_active) }
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
end
