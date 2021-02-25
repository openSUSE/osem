# frozen_string_literal: true

# == Schema Information
#
# Table name: votes
#
#  id         :bigint           not null, primary key
#  rating     :integer
#  created_at :datetime
#  updated_at :datetime
#  event_id   :integer
#  user_id    :integer
#
require 'spec_helper'

describe Vote do
  let!(:vote) { create(:vote) }

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:vote)).to be_valid
    end

    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:event_id) }

    # This is testing the relationship instead of using the shoulda-matchers
    context 'vote with user already exists' do
      it 'fails when adding vote twice for user and event' do
        expect { create(:vote, user: vote.user, event: vote.event) }
          .to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: User has already been taken')
      end
    end
  end
end
