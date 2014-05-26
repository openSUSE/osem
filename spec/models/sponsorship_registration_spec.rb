require 'spec_helper'

describe SponsorshipRegistration do
  describe 'validations' do 
    it 'has a valid factory' do
      expect(build(:sponsorship_registration)).to be_valid
    end

    it 'is not valid without a name' do
      should validate_presence_of(:name)
    end

    it 'is not valid without a email_id' do
      should validate_presence_of(:email_id)
    end

    it 'is not valid without a contact number' do
      should validate_presence_of(:contact_no)
    end

    it 'is not valid without a amount donated' do
      should validate_presence_of(:amount_donated)
    end

    it 'is not valid without a method of donation' do
      should validate_presence_of(:method_of_donation)
    end

    it 'is not valid without a sponsorship level' do
      should validate_presence_of(:sponsorship_level)
    end

    it 'is not valid without a organization' do
      should validate_presence_of(:organization)
    end

    it 'is not valid without a conference' do
      should validate_presence_of(:conference)
    end
  end
end
