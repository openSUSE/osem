# frozen_string_literal: true

require 'spec_helper'

describe Queries::Conferences, type: :query do
  describe '::conference_by_filter' do
    let!(:conference) { create :conference }
    it 'returns conference by flter' do
      result = described_class::conference_by_filter({
        id: conference.id
      })
      expect(result).to eq(conference)
    end
  end

  describe '.sponsorship_levels' do
    let!(:conference) { create :full_conference }
   
    it 'returns sponsorship_levels' do
      result = described_class.new(conference: conference).sponsorship_levels

      expect(result.map(&:id).sort).to eq(conference.sponsorship_levels.map(&:id).sort)
    end
  end

  describe '.confirmed_tracks' do
    let!(:conference) { create :full_conference }

    it 'returns confirmed_tracks' do
      result = described_class.new(conference: conference).confirmed_tracks

      expect(result.map(&:id).sort).to eq(conference.confirmed_tracks.map(&:id).sort)
    end
  end
end
