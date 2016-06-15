require 'spec_helper'

describe Program do
  let!(:conference) { create(:conference, end_date: Date.today + 3) }
  let!(:program) { conference.program }

  describe '#rating_enabled?' do
    it 'returns true if proposals can be rated (program.rating > 0)' do
      program.rating = 3
      expect(program.rating_enabled?).to be true
    end

    it 'returns false if proposals cannot be rated (program.rating == 0) ' do
      program = conference.program
      program.rating = 0
      expect(program.rating_enabled?).to be false
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

  describe 'languages' do
    it "is not valid if languages aren't two letters separated by commas" do
      program.languages = 'eng, De es'
      expect(program.valid?).to eq false
      expect(program.errors[:languages]).to eq ['must be two letters separated by commas']
    end

    it 'is not valid if languages are repeated' do
      program.languages = 'en,de,es,en'
      expect(program.valid?).to eq false
      expect(program.errors[:languages]).to eq ["can't be repeated"]
    end

    it "is not valid if languages aren't ISO 639-1 valid codes" do
      program.languages = 'en,hh,yu,zi,oo'
      expect(program.valid?).to eq false
      expect(program.errors[:languages]).to eq ['must be ISO 639-1 valid codes']
    end

    it 'is valid otherwise' do
      program.languages = 'en,De, ES, ru,el'
      expect(program.valid?).to eq true
    end
  end

  describe '#languages_list' do
    it 'returns the list of readable languages' do
      program.languages = 'en,de,fr,ru,zh'
      expect(program.languages_list).to eq %w(English German French Russian Chinese)
    end
  end

end
