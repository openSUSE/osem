#!/bin/env ruby
# encoding: utf-8
require 'spec_helper'

describe Conference do

  let(:subject) { create(:conference) }

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
      expect(build(:conference, title: nil)).to have(1).errors_on(:title)
    end

    it 'is not valid without a short title' do
      expect(build(:conference, short_title: nil)).to have(1)
                                                      .errors_on(:short_title)
    end

    it 'is not valid without a social tag' do
      expect(build(:conference, social_tag: nil)).to have(1)
                                                     .errors_on(:social_tag)
    end

    it 'is not valid without a start date' do
      expect(build(:conference, start_date: nil)).to have(1)
                                                     .errors_on(:start_date)
    end

    it 'is not valid without an end date' do
      expect(build(:conference, end_date: nil)).to have(1).errors_on(:end_date)
    end

    it 'is not valid with a duplicate short title' do
      create(:conference)
      expect(build(:conference)).to have(1).errors_on(:short_title)
    end

    it 'is valid with a short title that contains a-zA-Z0-9_-' do
      conference = build(:conference,
                         short_title: 'abc_xyz-ABC-XYZ-012_89')
      expect(conference).to be_valid
    end

    it 'is not valid with a short title that contains special characters' do
      conference = build(:conference,
                         short_title: '&%§!?äÄüÜ/()')
      expect(conference).to have(1).errors_on(:short_title)
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
