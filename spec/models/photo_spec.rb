require 'spec_helper'

describe Photo do
  describe 'validations' do

    it 'has a valid factory' do
      expect(build(:photo)).to be_valid
    end

    it 'is not valid without a picture' do
      should validate_presence_of(:picture)
    end
  end
end
