# frozen_string_literal: true

require 'spec_helper'

describe TrackType do
  let(:conference) { create(:conference) }
  let(:track_type) { create(:track_type, program: conference.program) }

  describe 'association' do
    it { is_expected.to belong_to :program }
  end

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:track_type)).to be_valid
    end

    it { is_expected.to validate_presence_of(:title) }

  end
end
