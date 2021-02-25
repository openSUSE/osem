# frozen_string_literal: true

# == Schema Information
#
# Table name: registration_periods
#
#  id            :bigint           not null, primary key
#  end_date      :date
#  start_date    :date
#  created_at    :datetime
#  updated_at    :datetime
#  conference_id :integer
#
require 'spec_helper'

describe RegistrationPeriod do
  let!(:conference) { create(:conference, start_date: Date.today, end_date: Date.today + 6) }
  let!(:registration_ticket) { create(:registration_ticket, conference: conference) }
  let!(:registration_period) { create(:registration_period, start_date: Date.today - 2, end_date: Date.today - 1, conference: conference) }

  describe 'validations' do
    it 'has a valid factory' do
      expect(build(:registration_period)).to be_valid
    end

    it 'is not valid without a start_date' do
      should validate_presence_of(:start_date)
    end

    it 'is not valid without an end_date' do
      should validate_presence_of(:end_date)
    end
  end

  describe '#before_end_of_conference' do
    context 'is valid' do
      it 'when start_date and end_date are before conference end_date' do
        registration_period.start_date = conference.end_date - 2
        registration_period.end_date = conference.end_date - 1
        expect(registration_period.valid?).to eq true
      end

      it 'when start_date and end_date are the same day as conference end_date' do
        registration_period.start_date = conference.end_date
        registration_period.end_date = conference.end_date
        expect(registration_period.valid?).to eq true
      end
    end

    context 'is invalid' do
      it 'when start_date and end_date are after conference end_date' do
        registration_period.start_date = conference.end_date + 1
        registration_period.end_date = conference.end_date + 2
        expect(registration_period.valid?).to eq false
      end

      it 'when end_date is after conference end_date' do
        registration_period.start_date = conference.end_date - 1
        registration_period.end_date = conference.end_date + 1
        expect(registration_period.valid?).to eq false
      end
    end
  end

  describe '#start_date_before_end_date' do
    context 'is valid' do
      it 'when start_date is before end_date' do
        registration_period.start_date = conference.end_date - 2
        registration_period.end_date = conference.end_date - 1
        expect(registration_period.valid?).to eq true
      end

      it 'when start_date and end_date are on the same day' do
        registration_period.start_date = conference.end_date - 2
        registration_period.end_date = conference.end_date - 2
        expect(registration_period.valid?).to eq true
      end
    end

    context 'is invalid' do
      it 'when start_date is after end_date' do
        registration_period.start_date = conference.start_date + 2
        registration_period.end_date = conference.start_date + 1
        expect(registration_period.valid?).to eq false
      end
    end
  end
end
