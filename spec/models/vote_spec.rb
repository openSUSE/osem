# frozen_string_literal: true

require 'spec_helper'

describe Vote do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let(:vote) { create(:vote, event: event, user: user) }

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:vote)).to be_valid
    end

    it 'validates uniqueness of event in scope of user' do
      expect(build(:vote, event: vote.event, user: vote.user)).not_to be_valid
    end
  end
end
