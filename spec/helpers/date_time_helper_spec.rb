# frozen_string_literal: true

require 'spec_helper'

describe DateTimeHelper, type: :helper do

  describe 'format_datetime' do
    it 'returns nothing if there is no parameter' do
      expect(format_datetime(nil)).to be_nil
    end

    it 'returns formatted string' do
      datetime = Time.zone.local(2016, 05, 04, 11, 30)
      expect(format_datetime(datetime)).to eq '2016-05-04 11:30'
    end
  end

  describe 'show_time' do
    it 'when length > 60' do
      expect(show_time(67)).to eq '1 h 7 min'
    end

    it 'when length = 60' do
      expect(show_time(60)).to eq '1 h'
    end

    it 'when length < 60' do
      expect(show_time(58)).to eq '58 min'
    end

    it 'when length > 60 and is a decimal number' do
      expect(show_time(68.3)).to eq '1 h 8 min'
    end

    it 'when length is nil' do
      expect(show_time(nil)).to eq '0 h 0 min'
    end
  end
end
