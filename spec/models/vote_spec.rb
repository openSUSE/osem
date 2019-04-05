# frozen_string_literal: true

require 'spec_helper'

describe Vote do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let(:vote) { create(:vote, event: event, user: user) }

  describe 'validation' do
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:event_id) }

    it 'has a valid factory' do
      expect(build(:vote)).to be_valid
    end
  end
end
