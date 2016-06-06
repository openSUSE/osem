require 'spec_helper'

describe Sponsor do
  subject { create(:events_registration) }

  describe 'association' do
    it { is_expected.to belong_to :event }
    it { is_expected.to belong_to :registration }
    it { is_expected.to have_one :user }
  end

  describe 'validations' do
    it 'has a valid factory' do
      expect(build(:events_registration)).to be_valid
    end

    it { is_expected.to validate_presence_of(:event) }
    it { is_expected.to validate_presence_of(:registration) }
    it { is_expected.to validate_uniqueness_of(:event).scoped_to(:registration_id) }
  end
end
