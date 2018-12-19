# frozen_string_literal: true

require 'spec_helper'

describe Commercial do

  describe '.find_since_last_login' do
    let!(:user) do
      create(:user, last_sign_in_at: nil)
    end

    it 'returns none if last_sign_in_at is nil' do
      expect(Comment.find_since_last_login(user)).to eq(Comment.none)
    end
  end
end
