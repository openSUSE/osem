require 'spec_helper'

describe RootRouteConstraint do
  describe '#matches?' do

    it 'returns false, if no conference is live' do
      constraint = RootRouteConstraint.new
      expect(constraint.matches?).to eq false
    end

    it 'returns false, when one conference is live but no splashpage' do
      create(:conference)
      constraint = RootRouteConstraint.new
      expect(constraint.matches?).to eq false
    end

    it 'returns false, when one conference is live but no public splashpage' do
      conference = create(:full_conference)
      conference.splashpage.public = false
      conference.splashpage.save
      constraint = RootRouteConstraint.new
      expect(constraint.matches?).to eq false
    end

    it 'returns true, when one conference is live and has public splashpage' do
      create(:full_conference)
      constraint = RootRouteConstraint.new
      expect(constraint.matches?).to eq true
    end

    it 'returns false, if more than one conference is live' do
      create(:full_conference)
      create(:full_conference)
      constraint = RootRouteConstraint.new
      expect(constraint.matches?).to eq false
    end

  end
end
