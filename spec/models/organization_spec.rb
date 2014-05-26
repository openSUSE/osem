require 'spec_helper'

describe Organization do
	describe 'validations' do
    it 'has a valid factory' do
      expect(build(:organization)).to be_valid
    end

    it 'is not valid without a title' do
      should validate_presence_of(:title)
    end

    it 'is not valid without a email id' do
      should validate_presence_of(:email_id)
    end

    it 'is not valid with a duplicate email_id' do
      should validate_uniqueness_of(:email_id)
    end
  end
end
