require 'spec_helper'

describe SponsorshipLevel do
  describe 'validations' do
    it 'it has valid factory' do
      expect(build(:sponsorship_level)).to be_valid
    end
    it 'is not valid without a title' do
      should validate_presence_of(:title)
    end
  end
end
