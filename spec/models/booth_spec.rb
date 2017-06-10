require 'spec_helper'

describe 'Booth' do
  subject { create(:booth) }
  let!(:conference) { create(:conference) }

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:booth)).to be_valid
    end

    it { is_expected.to validate_presence_of(:conference) }

    it 'is not valid without a title' do
      should validate_presence_of(:title)
    end
  end

  describe 'association' do
    it { is_expected.to belong_to(:conference) }
    it { is_expected.to have_many(:booth_requests) }
  end

end
