require 'spec_helper'

describe Organization do
  describe 'validations' do

    it 'has a valid factory' do
      expect(build(:organization)).to be_valid
    end

    it 'is not valid without a name' do
      should validate_presence_of(:name)
    end

    it 'is not valid without a website url' do
      should validate_presence_of(:website_url)
    end

    it 'is not valid with a duplicate website_url' do
      should validate_uniqueness_of(:website_url)
    end
  end
end
