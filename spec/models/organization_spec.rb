require 'spec_helper'

describe Organization do
  let(:organization) { create(:organization) }

  describe 'validation' do
    it 'is not valid without a name' do
      should validate_presence_of(:name)
    end
  end

  describe 'associations' do
    it { should have_many(:conferences).dependent(:destroy) }
  end
end
