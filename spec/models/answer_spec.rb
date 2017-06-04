require 'spec_helper'

describe Answer do
  describe 'association' do
    it { should have_many :qanswers }
    it { should have_many(:questions).through(:qanswers) }
  end

  describe 'validation' do
    it 'has valid factory' do
      expect(build(:answer)).to be_valid
    end

    it{ is_expected.to validate_presence_of(:title) }
  end
end
