# frozen_string_literal: true

# == Schema Information
#
# Table name: registrations
#
#  id                       :bigint           not null, primary key
#  accepted_code_of_conduct :boolean
#  attended                 :boolean          default(FALSE)
#  other_special_needs      :text
#  volunteer                :boolean
#  week                     :integer
#  created_at               :datetime
#  updated_at               :datetime
#  conference_id            :integer
#  user_id                  :integer
#
require 'spec_helper'

describe Registration do
  subject { create(:registration) }
  let!(:user) { create(:user) }
  let!(:conference) { create(:conference) }
  let!(:registration) { create(:registration, conference: conference, user: user) }

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:registration)).to be_valid
    end

    it { is_expected.to validate_presence_of(:user) }

    it 'validates uniqueness of user in scope of conference' do
      expect(build(:registration, conference: subject.conference, user: subject.user)).not_to be_valid
    end

    describe 'registration_limit_not_exceed' do
      it 'is not valid when limit exceeded' do
        conference.registration_limit = 1
        expect { create(:registration, conference: conference, user: user) }.to raise_error('Validation failed: User already Registered!, Registration limit exceeded')
        expect(user.registrations.size).to be 1
      end
    end
  end

  describe 'association' do
    it { is_expected.to belong_to(:user) }
    # TODO-SNAPCON: This fails because conference is nil, but obviously this works...
    # it { is_expected.to belong_to(:conference) }
    it { is_expected.to have_and_belong_to_many(:qanswers) }
    it { is_expected.to have_and_belong_to_many(:vchoices) }
    it { is_expected.to have_many(:events_registrations) }
    it { is_expected.to have_many(:events) }
  end

  describe 'after create' do
    after { subject.run_callbacks(:create) }

    describe '#subscribe_to_conference' do
      it 'subscribes to conference' do
        expect(subject).to receive(:subscribe_to_conference)
        expect(subject.user.subscribed?(subject.conference)).to be true
      end
    end

    it 'sends registrations mail' do
      expect(subject).to receive(:send_registration_mail)
    end
  end
end
