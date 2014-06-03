#!/bin/env ruby
# encoding: utf-8
require 'spec_helper'

describe Conference do

  let(:subject) { create(:conference) }

  describe '#get_status' do

    before(:each) do
      # Setup positive result hash
      @result = {}
      @result['registration'] = true
      @result['cfp'] = true
      @result['venue'] = true
      @result['rooms'] = true
      @result['tracks'] = true
      @result['event_types'] = true
      @result['difficulty_levels'] = true

      # Setup negative result hash
      @result_false = Hash.new
      @result.each { |key, value| @result_false[key] = !value }

      @result['short_title'] = @result_false['short_title'] = subject.short_title
      @result['process'] = 100.to_s
      @result_false['process'] = 0.to_s
    end

    it 'calculates correct for new conference' do
      subject.registration_start_date = nil
      subject.registration_end_date = nil
      subject.call_for_papers = nil
      subject.venue = nil
      subject.rooms = []
      subject.tracks = []
      subject.event_types = []
      subject.difficulty_levels = []

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with registration' do
      subject.registration_start_date = Date.today
      subject.registration_end_date = Date.today + 14
      subject.call_for_papers = nil
      subject.rooms = []
      subject.tracks = []
      subject.event_types = []
      subject.difficulty_levels = []

      @result_false['registration'] = true
      @result_false['process'] = 14.to_s

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with registration, cfp' do
      subject.registration_start_date = Date.today
      subject.registration_end_date = Date.today + 14
      subject.call_for_papers = create(:call_for_papers)
      subject.rooms = []
      subject.tracks = []
      subject.event_types = []
      subject.difficulty_levels = []

      @result_false['cfp'] = true
      @result_false['registration'] = true
      @result_false['process'] = 29.to_s

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with registration, cfp, venue' do
      subject.registration_start_date = Date.today
      subject.registration_end_date = Date.today + 14
      subject.call_for_papers = create(:call_for_papers)
      subject.venue = create(:venue)
      subject.rooms = []
      subject.tracks = []
      subject.event_types = []
      subject.difficulty_levels = []

      @result_false['cfp'] = true
      @result_false['registration'] = true
      @result_false['venue'] = true
      @result_false['process'] = 43.to_s

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with registration, cfp, venue, rooms' do
      subject.rooms = [create(:room)]
      subject.registration_start_date = Date.today
      subject.registration_end_date = Date.today + 14
      subject.call_for_papers = create(:call_for_papers)
      subject.venue = create(:venue)
      subject.tracks = []
      subject.event_types = []
      subject.difficulty_levels = []

      @result_false['cfp'] = true
      @result_false['registration'] = true
      @result_false['venue'] = true
      @result_false['rooms'] = true
      @result_false['process'] = 57.to_s

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with registration, cfp, venue, rooms, tracks' do
      subject.rooms = [create(:room)]
      subject.tracks = [create(:track)]
      subject.registration_start_date = Date.today
      subject.registration_end_date = Date.today + 14
      subject.call_for_papers = create(:call_for_papers)
      subject.venue = create(:venue)
      subject.event_types = []
      subject.difficulty_levels = []

      @result_false['cfp'] = true
      @result_false['registration'] = true
      @result_false['venue'] = true
      @result_false['rooms'] = true
      @result_false['tracks'] = true
      @result_false['process'] = 71.to_s

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with registration, cfp,
                                      venue, rooms, tracks, event_types' do
      subject.rooms = [create(:room)]
      subject.tracks = [create(:track)]
      subject.event_types = [create(:event_type)]
      subject.registration_start_date = Date.today
      subject.registration_end_date = Date.today + 14
      subject.call_for_papers = create(:call_for_papers)
      subject.venue = create(:venue)
      subject.difficulty_levels = []

      @result_false['cfp'] = true
      @result_false['registration'] = true
      @result_false['venue'] = true
      @result_false['rooms'] = true
      @result_false['tracks'] = true
      @result_false['event_types'] = true
      @result_false['process'] = 86.to_s

      expect(subject.get_status).to eq(@result_false)
    end

    it 'calculates correct for conference with all mandatory options' do
      subject.rooms = [create(:room)]
      subject.tracks = [create(:track)]
      subject.event_types = [create(:event_type)]
      subject.difficulty_levels = [create(:difficulty_level)]
      subject.registration_start_date = Date.today
      subject.registration_end_date = Date.today + 14
      subject.venue = create(:venue)
      subject.call_for_papers = create(:call_for_papers)
      subject.venue = create(:venue)

      expect(subject.get_status).to eq(@result)
    end
  end

  describe '#registration_weeks' do

    it 'calculates new year' do
      subject.registration_start_date = Date.new(2013, 12, 31)
      subject.registration_end_date = Date.new(2013, 12, 30) + 6
      expect(subject.registration_weeks).to eq(1)
    end

    it 'is one if start and end are 6 days apart' do
      subject.registration_start_date = Date.new(2014, 05, 26)
      subject.registration_end_date = Date.new(2014, 05, 26) + 6
      expect(subject.registration_weeks).to eq(1)
    end

    it 'is one if start and end date are the same' do
      subject.registration_start_date = Date.new(2014, 05, 26)
      subject.registration_end_date = Date.new(2014, 05, 26)
      expect(subject.registration_weeks).to eq(1)
    end

    it 'is two if start and end are 10 days apart' do
      subject.registration_start_date = Date.new(2014, 05, 26)
      subject.registration_end_date = Date.new(2014, 05, 26) + 10
      expect(subject.registration_weeks).to eq(2)
    end
  end

  describe '#cfp_weeks' do

    it 'calculates new year' do
      cfp = create(:call_for_papers)
      cfp.start_date = Date.new(2013, 12, 30)
      cfp.end_date = Date.new(2013, 12, 30) + 6
      subject.call_for_papers = cfp
      expect(subject.cfp_weeks).to eq(1)
    end

    it 'is one if start and end are 6 days apart' do
      cfp = create(:call_for_papers)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 6
      subject.call_for_papers = cfp
      expect(subject.cfp_weeks).to eq(1)
    end

    it 'is one if start and end are the same date' do
      cfp = create(:call_for_papers)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26)
      subject.call_for_papers = cfp
      expect(subject.cfp_weeks).to eq(1)
    end

    it 'is two if start and end are 10 days apart' do
      cfp = create(:call_for_papers)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 10
      subject.call_for_papers = cfp
      expect(subject.cfp_weeks).to eq(2)
    end
  end

  describe '#get_submissions_per_week' do

    it 'does calculate correct if cfp start date is altered' do
      cfp = create(:call_for_papers)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      subject.call_for_papers = cfp
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) - 7)]
      expect(subject.get_submissions_per_week).to eq([1, 1, 1, 1, 1])
    end

    it 'does calculate correct if cfp end date is altered' do
      cfp = create(:call_for_papers)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      subject.call_for_papers = cfp
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 28)]
      expect(subject.get_submissions_per_week).to eq([0, 0, 0, 0, 1])
    end

    it 'pads with zeros if there are no submissions' do
      cfp = create(:call_for_papers)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      subject.call_for_papers = cfp
      expect(subject.get_submissions_per_week).to eq([0, 0, 0, 0])
    end

    it 'summarized correct if there are no submissions in one week' do
      cfp = create(:call_for_papers)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 28
      subject.call_for_papers = cfp
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 7)]
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 14)]
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 28)]
      expect(subject.get_submissions_per_week).to eq([0, 1, 2, 2, 3])
    end

    it 'summarized correct if there are submissions every week except the first' do
      cfp = create(:call_for_papers)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      subject.call_for_papers = cfp
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 7)]
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 14)]
      expect(subject.get_submissions_per_week).to eq([0, 1, 2, 2])
    end

    it 'summarized correct if there are submissions every week' do
      cfp = create(:call_for_papers)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      subject.call_for_papers = cfp
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26))]
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 7)]
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 14)]
      expect(subject.get_submissions_per_week).to eq([1, 2, 3, 3])
    end

    it 'pads left' do
      cfp = create(:call_for_papers)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      subject.call_for_papers = cfp
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 21)]
      expect(subject.get_submissions_per_week).to eq([0, 0, 0, 1])
    end

    it 'pads middle' do
      cfp = create(:call_for_papers)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      subject.call_for_papers = cfp
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26))]
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26) + 21)]
      expect(subject.get_submissions_per_week).to eq([1, 1, 1, 2])
    end

    it 'pads right' do
      cfp = create(:call_for_papers)
      cfp.start_date = Date.new(2014, 05, 26)
      cfp.end_date = Date.new(2014, 05, 26) + 21
      subject.call_for_papers = cfp
      subject.events += [create(:event, created_at: Date.new(2014, 05, 26))]
      expect(subject.get_submissions_per_week).to eq([1, 1, 1, 1])
    end
  end

  describe '#get_registrations_per_week' do

    it 'pads with zeros if there are no registrations' do
      subject.registration_start_date = Date.new(2014, 05, 26)
      subject.registration_end_date = Date.new(2014, 05, 26) + 21

      expect(subject.get_registrations_per_week).to eq([0, 0, 0, 0])
    end

    it 'summarized correct if there are no registrations in one week' do
      subject.registration_start_date = Date.new(2014, 05, 26)
      subject.registration_end_date = Date.new(2014, 05, 26) + 28

      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 7)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 14)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 28)

      expect(subject.get_registrations_per_week).to eq([0, 1, 2, 2, 3])
    end

    it 'returns [1] if there is one registration on the first day' do
      subject.registration_start_date = Date.new(2014, 05, 26)
      subject.registration_end_date = Date.new(2014, 05, 26) + 7

      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26))
      expect(subject.get_registrations_per_week).to eq([1, 1])
    end

    it 'summarized correct if there are registrations every week' do
      subject.registration_start_date = Date.new(2014, 05, 26)
      subject.registration_end_date = Date.new(2014, 05, 26) + 21

      create(:registration, conference: subject, created_at: Date.new(2014, 05, 26))
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 7)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 14)

      expect(subject.get_registrations_per_week).to eq([1, 2, 3, 3])
    end

    it 'summarized correct if there are registrations every week except the first' do
      subject.registration_start_date = Date.new(2014, 05, 26)
      subject.registration_end_date = Date.new(2014, 05, 26) + 28

      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 7)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 14)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 28)

      expect(subject.get_registrations_per_week).to eq([0, 1, 2, 2, 3])
    end

    it 'pads left' do
      subject.registration_start_date = Date.new(2014, 05, 26)
      subject.registration_end_date = Date.new(2014, 05, 26) + 35

      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 21)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 28)
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 35)

      expect(subject.get_registrations_per_week).to eq([0, 0, 0, 1, 2, 3])
    end

    it 'pads middle' do
      subject.registration_start_date = Date.new(2014, 05, 26)
      subject.registration_end_date = Date.new(2014, 05, 26) + 35

      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26))
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 35)

      expect(subject.get_registrations_per_week).to eq([1, 1, 1, 1, 1, 2])
    end

    it 'pads right' do
      subject.registration_start_date = Date.new(2014, 05, 26)
      subject.registration_end_date = Date.new(2014, 05, 26) + 35

      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26))
      create(:registration, conference: subject,
                            created_at: Date.new(2014, 05, 26) + 7)

      expect(subject.get_registrations_per_week).to eq([1, 2, 2, 2, 2, 2])
    end
  end

  describe '#pending?' do

    context 'is pending' do

      it '#pending? is true' do
        subject.start_date = Date.today + 10
        expect(subject.pending?).to be true
      end
    end

    context 'is not pending' do

      it '#pending? is false' do
        subject.start_date = Date.today - 10
        expect(subject.pending?).to be false
      end
    end
  end

  describe '#registration_open?' do

    context 'closed registration' do

      it '#registration_open? is false' do
        expect(subject.registration_open?).to be false
      end
    end

    context 'open registration' do

      before do
        subject.registration_start_date = Date.today - 1
        subject.registration_end_date = Date.today + 7
      end

      it '#registration_open? is true' do
        expect(subject.registration_open?).to be true
      end
    end
  end

  describe '#cfp_open?' do

    context 'closed cfp' do

      it '#cfp_open? is false' do
        expect(subject.cfp_open?).to be false
      end

    end

    context 'open cfp' do

      before do
        subject.call_for_papers = create(:call_for_papers)
      end

      it '#registration_open? is true' do
        expect(subject.cfp_open?).to be true
      end
    end
  end

  describe '#user_registered?' do

    # It is necessary to use bang version of let to build roles before user
    let!(:organizer_role) { create(:organizer_role) }
    let!(:participant_role) { create(:participant_role) }
    let!(:admin_role) { create(:admin_role) }

    let(:user) { create(:user) }

    context 'user not registered' do
      it '#user_registered? is false' do
        expect(subject.user_registered? user).to be false
      end
    end

    context 'user registered' do
      pending "isn't tested yet"
    end
  end

  describe 'validations' do

    it 'has a valid factory' do
      expect(build(:conference)).to be_valid
    end

    it 'is not valid without a title' do
      should validate_presence_of(:title)
    end

    it 'is not valid without a short title' do
      should validate_presence_of(:short_title)
    end

    it 'is not valid without a social tag' do
      should validate_presence_of(:social_tag)
    end

    it 'is not valid without a start date' do
      should validate_presence_of(:start_date)
    end

    it 'is not valid without an end date' do
      should validate_presence_of(:end_date)
    end

    it 'is not valid with a duplicate short title' do
      should validate_uniqueness_of(:short_title)
    end

    it 'is valid with a short title that contains a-zA-Z0-9_-' do
      should allow_value('abc_xyz-ABC-XYZ-012_89').for(:short_title)
    end

    it 'is not valid with a short title that contains special characters' do
      should_not allow_value('&%§!?äÄüÜ/()').for(:short_title)
    end

    describe 'before create callbacks' do

      it 'has an email setting after creation' do
        expect(subject.email_settings).not_to be_nil
      end

      it 'has a venue after creation' do
        expect(subject.venue).not_to be_nil
      end

      it 'has a guid after creation' do
        expect(subject.guid).not_to be_nil
      end
    end
  end
end
