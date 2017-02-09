require 'spec_helper'

describe Resource do
  let(:conference) { create(:conference) }
  let(:resource) { create :resource }

  it 'has a valid factory' do
    expect(build(:resource)).to be_valid
  end

  it 'is not valid with used greater than quantity' do
    resource.used = resource.quantity + 1
    expect(resource.valid?).to eq false
  end
end
