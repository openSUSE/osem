# frozen_string_literal: true

# == Schema Information
#
# Table name: resources
#
#  id            :bigint           not null, primary key
#  description   :text
#  name          :string
#  quantity      :integer
#  used          :integer          default(0)
#  conference_id :integer
#
require 'spec_helper'

describe Resource do
  let(:conference) { create(:conference) }
  let(:resource) { create :resource }

  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to validate_presence_of(:used) }

  it { is_expected.to validate_presence_of(:quantity) }

  it { is_expected.to validate_numericality_of(:used) }

  it { is_expected.to validate_numericality_of(:quantity) }

  it { is_expected.not_to allow_value(-1).for(:used) }

  it { is_expected.to allow_value(0).for(:used) }

  it { is_expected.not_to allow_value(-1).for(:quantity) }

  it { is_expected.to allow_value(0).for(:quantity) }

  it 'has a valid factory' do
    expect(build(:resource)).to be_valid
  end

  it 'is not valid with used greater than quantity' do
    resource.used = resource.quantity + 1
    expect(resource.valid?).to eq false
  end
end
