require 'spec_helper'

describe Program do
  let!(:conference) { create(:conference, end_date: Date.today + 3) }
  let!(:program) { conference.program }

  describe '#rating_enabled?' do
    it 'returns true if proposals can be rated (program.rating > 0)' do
      program.rating = 3
      expect(program.rating_enabled?).to be true
    end

    it 'returns false if proposals cannot be rated (program.ratinig == 0) ' do
      program = conference.program
      program.rating = 3
      expect(program.rating_enabled?).to be true
    end
  end

  describe '#cfp_open?' do
    describe 'returns true' do
      it 'when there is an open Call for Papers for the conference' do
        create(:cfp, start_date: Date.today - 2, end_date: Date.today, program_id: program.id)
        expect(program.cfp_open?).to be true
      end
    end

    describe 'returns false' do
      it 'when there is no Call for Papers for the conference' do
        expect(program.cfp_open?).to be false
      end

      it 'when the Call for Papers period is over' do
        build(:cfp, start_date: Date.today - 2, end_date: Date.today - 1, program_id: program.id)
        expect(program.cfp_open?).to be false
      end
    end
  end

  describe 'excecutes before_create functions' do
    it 'and creates events_types' do
      program.destroy!
      conference.reload
      expect(conference.program).to eq nil

      create(:program, conference_id: conference.id)
      conference.reload
      expect(conference.program.event_types.count).to eq 2
    end

    it 'and creates difficulty_levels' do
      program.destroy!
      conference.reload
      expect(conference.program).to eq nil

      create(:program, conference_id: conference.id)
      conference.reload
      expect(conference.program.difficulty_levels.count).to eq 3
    end
  end
end
