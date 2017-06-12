require 'spec_helper'

describe Program do
  subject { create(:program) }
  let!(:conference) { create(:conference, end_date: Date.today + 3) }
  let!(:program) { conference.program }

  describe 'association' do
    it { is_expected.to belong_to :conference }
    it { is_expected.to have_one(:cfp).dependent(:destroy) }
    it { is_expected.to have_many(:schedules).dependent(:destroy) }
    it { is_expected.to have_many(:event_types).dependent(:destroy) }
    it { is_expected.to have_many(:tracks).dependent(:destroy) }
    it { is_expected.to have_many(:difficulty_levels).dependent(:destroy) }
    it { is_expected.to have_many(:events).dependent(:destroy) }
    it { is_expected.to have_many(:event_schedules).through(:events) }
    it { is_expected.to have_many(:event_users).through(:events) }
    it { is_expected.to have_many(:speakers).through(:event_users).source(:user) }

    it { is_expected.to accept_nested_attributes_for(:event_types) }
    it { is_expected.to accept_nested_attributes_for(:tracks) }
    it { is_expected.to accept_nested_attributes_for(:difficulty_levels) }
  end

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:program)).to be_valid
    end

    it 'is valid for rating of 5' do
      expect(build(:program, rating: 5)).to be_valid
    end

    it { is_expected.to validate_numericality_of(:rating).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(10).only_integer }

    it { is_expected.to validate_numericality_of(:schedule_interval).is_greater_than_or_equal_to(5).is_less_than_or_equal_to(60) }

    describe 'schedule_interval_divisor_60' do
      it 'is valid, when schedule_interval is divisor of 60' do
        expect(build(:program, schedule_interval: 20)).to be_valid
      end

      it 'is not valid, when schedule_interval is not divisor of 60' do
        expect(build(:program, schedule_interval: 35)).to_not be_valid
      end
    end

    describe 'voting_start_date_before_end_date' do
      it 'is valid, when voting_start_date is the same day as voting_end_date' do
        expect(build(:program, voting_start_date: Date.today, voting_end_date: Date.today)).to be_valid
      end

      it 'is valid, when voting_start_date is before voting_end_date' do
        expect(build(:program, voting_start_date: Date.today, voting_end_date: Date.today + 1)).to be_valid
      end

      it 'is not valid, when voting_start_date is after voting_end_date' do
        expect(build(:program, voting_start_date: Date.today, voting_end_date: Date.today - 1)).to_not be_valid
      end
    end

    describe 'voting_dates_exist' do
      it 'is valid, when both voting_start_date and voting_end_date are set' do
        expect(build(:program, voting_start_date: Date.today, voting_end_date: Date.today + 1)).to be_valid
      end

      it 'is invalid, when voting_start_date is not set' do
        expect(build(:program, voting_end_date: Date.today)).to_not be_valid
      end

      it 'is invalid, when voting_end_date is not set' do
        expect(build(:program, voting_start_date: Date.today)).to_not be_valid
      end
    end
  end

  describe '#show_voting?' do
    context 'blind voting is disabled' do
      before :each do
        program.blind_voting = false
      end
      it 'returns true if blind_voting is disabled' do
        program.blind_voting = false
        expect(program.show_voting?).to eq true
      end
    end

    context 'blind voting is enabled' do
      before :each do
        program.blind_voting = true
      end

      it 'returns true if voting period is over' do
        program.voting_end_date = Date.today - 1
        expect(program.show_voting?).to eq true
      end

      it 'returns false if we are still in votig period' do
        program.voting_end_date = Date.today + 1
        expect(program.show_voting?).to eq false
      end
    end
  end

  describe 'voting_period?' do
    it 'retuns true when voting dates are not set' do
      expect(program.voting_period?).to eq true
    end

    shared_examples 'voting period' do |voting_start_date, voting_end_date, returns|
      scenario 'returns true or false' do
        program.voting_start_date = voting_start_date
        program.voting_end_date = voting_end_date
        program.save!

        expect(program.voting_period?).to eq returns
      end
    end

    context 'voting dates are set' do
      it_behaves_like 'voting period', Date.today - 1, Date.today + 1, true
      it_behaves_like 'voting period', Date.today - 1, Time.current + 1.hour, true
      it_behaves_like 'voting period', Date.today - 2, Date.today - 1, false
      it_behaves_like 'voting period', Date.today - 1, Time.current - 1.minute, false
    end
  end

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
        create(:cfp, start_date: Date.current - 2, end_date: Date.current, program_id: program.id)
        expect(program.cfp_open?).to be true
      end
    end

    describe 'returns false' do
      it 'when there is no Call for Papers for the conference' do
        expect(program.cfp_open?).to be false
      end

      it 'when the Call for Papers period is over' do
        create(:cfp, start_date: Date.current - 2, end_date: Date.current - 1, program_id: program.id)
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

  describe 'excecutes after_save functions' do
    it 'and unschedule unfit events if schedule interval was changed' do
      start_date = program.conference.start_date.to_datetime.change(hour: program.conference.start_hour)
      create(:event_schedule, event: create(:event, program: program), start_time: start_date.change(min: program.schedule_interval))
      create(:event_schedule, event: create(:event, program: program), start_time: start_date)
      expect(program.event_schedules.count).to eq 2

      program.schedule_interval = 10
      program.save!
      program.reload
      expect(program.event_schedules.count).to eq 1
      expect(program.event_schedules.first.start_time).to eq start_date
    end

    it 'and change event type length if schedule interval was changed' do
      program.schedule_interval = 5
      program.save!

      program.event_types.first.update_attributes length: 5
      program.event_types.last.update_attributes length: 25
      create(:event_type, program: program, length: 30)

      program.schedule_interval = 10
      program.save!
      expect(program.event_types.pluck(:length).sort).to eq [10, 20, 30]
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
