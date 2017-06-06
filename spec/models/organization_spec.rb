require 'spec_helper'

describe Organization do
  let(:organization) { create(:organization) }

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:organization)).to be_valid
    end

    it 'is not valid without a name' do
      should validate_presence_of(:name)
    end
  end

  describe 'associations' do
    it { should have_many(:conferences).dependent(:destroy) }
  end
end
