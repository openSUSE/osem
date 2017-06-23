require 'spec_helper'

describe CallForBooth do
  it 'has a valid factory' do
    expect(build(:call_for_booths)).to be_valid
  end

  it 'is not valid without a start_date' do
    should validate_presence_of(:start_date)
  end

  it 'is not valid without an end_date' do
    should validate_presence_of(:end_date)
  end
end
