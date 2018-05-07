# frozen_string_literal: true

require 'spec_helper'

describe Target do
  let(:registration_target) { create(:target, target_count: 10, unit: Target.units[:registrations]) }
  let(:submission_target) { create(:target, target_count: 10, unit: Target.units[:submissions]) }
  let(:program_minutes_target) { create(:target, target_count: 300, unit: Target.units[:program_minutes]) }

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:target)).to be_valid
    end

    it 'is not valid without a due date' do
      should validate_presence_of(:due_date)
    end

    it 'is not valid without a target_count' do
      should validate_presence_of(:target_count)
    end

    it 'is not valid without a unit' do
      should validate_presence_of(:unit)
    end

    it 'is valid with a target_count greater than zero' do
      should allow_value(10).for(:target_count)
    end

    it 'is not valid with a target_count equals zero' do
      should_not allow_value(0).for(:target_count)
    end

    it 'is not valid with a target_count smaller than zero' do
      should_not allow_value(-10).for(:target_count)
    end
  end

  describe 'default scope' do
    before do
      @first_target = create(:target, due_date: 2.days.from_now)
      @second_target = create(:target, due_date: 3.days.from_now)
    end

    it 'orders by ascending due_date' do
      expect(Target.all).to match_array [@first_target, @second_target]
    end
  end

  describe 'association' do
    it { should belong_to(:conference) }
    it { should belong_to(:campaign) }
  end

  describe '#get_progress' do
    it 'returns zero, when there are no registrations' do
      expect(registration_target.get_progress).to eq('0')
    end

    it 'returns 10, when there is 1 registration and the target is 10' do
      create(:registration, conference: registration_target.conference)

      expect(registration_target.get_progress).to eq('10')
    end

    it 'returns zero, when there are no submissions' do
      expect(submission_target.get_progress).to eq('0')
    end

    it 'returns 10, when there is 1 submission and the target is 10' do
      create(:event, program: submission_target.conference.program)

      expect(submission_target.get_progress).to eq('10')
    end

    it 'returns zero, when there are no program minutes' do
      expect(program_minutes_target.get_progress).to eq('0')
    end

    it 'returns 10, when there are 30 program minutes and the target is 300' do
      create(:event, program: program_minutes_target.conference.program)

      expect(program_minutes_target.get_progress).to eq('10')
    end
  end

  describe '#get_campaign' do
    context 'submissions' do
      before do
        submission_target.campaign = create(:campaign, name: 'Submission Campaign', conference: submission_target.conference)
        submission_target.created_at = Time.utc(2014, 5, 10)
        submission_target.due_date = Date.today + 4.days
        allow(submission_target.campaign).to receive(:submissions_count) { 20 }
      end

      it 'returns a hash with values of the corresponding campaign submissions' do
        result = {
          'target_name' => "10 Submissions by #{Date.today + 4.days}",
          'campaign_name' => 'Submission Campaign',
          'value' => 20,
          'unit' => 'Submission',
          'created_at' => Time.utc(2014, 5, 10).in_time_zone,
          'progress' => '200',
          'days_left' => 4
        }

        expect(submission_target.get_campaign).to eq result
      end
    end

    context 'registrations' do
      before do
        registration_target.campaign = create(:campaign, name: 'Registration Campaign', conference: registration_target.conference)
        registration_target.created_at = Time.utc(2014, 5, 10)
        registration_target.due_date = Date.today + 4.days
        allow(registration_target.campaign).to receive(:registrations_count) { 20 }
      end

      it 'returns a hash with values of the corresponding campaign registrations' do
        result = {
          'target_name' => "10 Registrations by #{Date.today + 4.days}",
          'campaign_name' => 'Registration Campaign',
          'value' => 20,
          'unit' => 'Registration',
          'created_at' => Time.utc(2014, 5, 10).in_time_zone,
          'progress' => '200',
          'days_left' => 4
        }

        expect(registration_target.get_campaign).to eq result
      end
    end

    context 'program_minutes' do
      before do
        program_minutes_target.campaign = create(:campaign, name: 'Program Campaign', conference: program_minutes_target.conference)
        program_minutes_target.created_at = Time.utc(2014, 5, 10)
        program_minutes_target.due_date = Date.today + 4.days
        allow(program_minutes_target.conference).to receive(:current_program_minutes) { 20 }
      end

      it 'returns a hash with values of the corresponding campaign program minutes' do
        result = {
          'target_name' => "300 Program minutes by #{Date.today + 4.days}",
          'campaign_name' => 'Program Campaign',
          'value' => 20,
          'unit' => 'Program minute',
          'created_at' => Time.utc(2014, 5, 10).in_time_zone,
          'progress' => '7',
          'days_left' => 4
        }

        expect(program_minutes_target.get_campaign).to eq result
      end
    end
  end

  describe '#to_s' do
    it 'returns a string in the correct format' do
      result = "10 Registrations by #{14.days.from_now.to_date}"

      expect(registration_target.to_s).to eq(result)
    end
  end
end
