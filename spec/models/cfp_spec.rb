require 'spec_helper'

describe CallForPaper do
  let!(:conference) { create(:conference, end_date: Date.today) }

  describe '#before_end_of_conference' do
    describe 'fails to save cfp' do
      it 'when cfp end_date is after conference end_date' do
        cfp = build(:call_for_paper, end_date: Date.today + 1, conference_id: conference.id)
	expect(cfp.valid?).to be false
      end

      it 'when cfp start_date is after conference end_date' do
	cfp = build(:call_for_paper, end_date: Date.today + 1, conference_id: conference.id)
	expect(cfp.valid?).to be false
      end
    end

    describe 'successfully saves cfp' do
      it 'when cfp end_date and start_date are not after conference end_date' do
	cfp = build(:call_for_paper, start_date: Date.today - 2, end_date: Date.today - 1, conference_id: conference.id)
	expect(cfp.valid?).to be true
      end
    end
  end

  describe '#start_after_end_date' do
    it 'fails when cfp start_date is after cfp end_date' do
      cfp = build(:call_for_paper, start_date: Date.today - 1, end_date: Date.today - 2, conference_id: conference.id)
      expect(cfp.valid?).to be false
    end

    it 'succeeds when cfp start_date is after cfp end_date' do
      cfp = build(:call_for_paper, start_date: Date.today - 2, end_date: Date.today - 1, conference_id: conference.id)
      expect(cfp.valid?).to be true
    end
  end
end
